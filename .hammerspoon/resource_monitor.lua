local M = {}

-----------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------

local TARGET_APPS = { "Ghostty", "Antigravity", "Safari", "Ollama", "Hammerspoon", "Docker", "Spotify" }

local WIDTH = 320
local PAD_X = 10
local PAD_Y = 6
local LINE_H = 17
local FONT_SIZE = 11.5
local FONT = "SF Mono"
local UPDATE_INTERVAL = 5

local panel = nil
local panelTimer = nil
local dragging = false
local dragOffset = nil
local menubar = nil
local dragCallback = nil

local clickThrough = hs.settings.get("resourceMonitorClickThrough")
if clickThrough == nil then
	clickThrough = true -- default to click-through as requested by user
end

-----------------------------------------------------------------------
-- DATA GATHERING
-----------------------------------------------------------------------

--- Gather per-app stats and top 3 processes from a single `ps` call.
local TOP_N = 3

local function gatherStats()
	local output = hs.execute("ps -eo %cpu,rss,comm")
	local stats = {}

	for _, app in ipairs(TARGET_APPS) do
		stats[app] = { cpu = 0, mem = 0, count = 0 }
	end

	-- collect all processes for top-N sorting
	local allProcs = {}

	for line in output:gmatch("[^\r\n]+") do
		local cpuStr, rssStr, comm = line:match("%s*([%d%.]+)%s+(%d+)%s+(.+)")
		local cpu = tonumber(cpuStr)
		local rss = tonumber(rssStr)

		if cpu and rss and comm then
			-- tracked apps
			for _, app in ipairs(TARGET_APPS) do
				if comm:lower():find(app:lower(), 1, true) then
					stats[app].cpu = stats[app].cpu + cpu
					stats[app].mem = stats[app].mem + rss
					stats[app].count = stats[app].count + 1
				end
			end

			-- top processes (by CPU)
			local name = comm:match("[^/]+$") or comm
			table.insert(allProcs, { name = name, cpu = cpu, mem = rss })
		end
	end

	-- sort by CPU descending and take top N
	table.sort(allProcs, function(a, b) return a.cpu > b.cpu end)
	local topProcs = {}
	for i = 1, math.min(TOP_N, #allProcs) do
		table.insert(topProcs, allProcs[i])
	end

	return stats, topProcs
end

--- Format memory in KB to a compact human-readable string.
local function fmtMem(rssKB)
	if rssKB >= 1024 * 1024 then
		return string.format("%7.1f GB", rssKB / (1024 * 1024))
	else
		return string.format("%7.1f MB", rssKB / 1024)
	end
end

--- System-wide CPU usage.
local function sysCpu()
	local ok, cpu = pcall(function()
		return hs.host.cpuUsage()
	end)
	if ok and cpu and cpu.overall and cpu.overall.active then
		return string.format("%.1f%%", cpu.overall.active)
	end
	return "–"
end

--- System-wide memory: used / total.
local function sysMem()
	-- parse vm_stat for page counts
	local out = hs.execute("vm_stat 2>/dev/null")
	if not out then
		return "–"
	end

	local function grab(label)
		local val = out:match(label .. "%s*:%s*(%d+)")
		return tonumber(val) or 0
	end

	local pageSize = tonumber(out:match("page size of (%d+)")) or 16384
	local active = grab("Pages active")
	local inactive = grab("Pages inactive")
	local wired = grab("Pages wired down")
	local used = (active + inactive + wired) * pageSize

	-- total physical RAM from sysctl
	local totalStr = hs.execute("sysctl -n hw.memsize 2>/dev/null"):gsub("%s+", "")
	local total = tonumber(totalStr) or 0

	if total > 0 then
		return string.format("%.1f / %.0f GB", used / 1024 / 1024 / 1024, total / 1024 / 1024 / 1024)
	end
	return string.format("%.1f GB", used / 1024 / 1024 / 1024)
end

--- Network throughput (bytes/sec since last call).
local netPrev = nil
local netPrevTime = nil

local function netThroughput()
	local out = hs.execute("netstat -ib 2>/dev/null | head -20")
	local totalIn, totalOut = 0, 0

	local headerParsed = false
	local ibyteIdx, obyteIdx = nil, nil

	for line in out:gmatch("[^\r\n]+") do
		if not headerParsed then
			local cols = {}
			for word in line:gmatch("%S+") do
				table.insert(cols, word)
			end
			for i, col in ipairs(cols) do
				if col == "Ibytes" then
					ibyteIdx = i
				end
				if col == "Obytes" then
					obyteIdx = i
				end
			end
			headerParsed = true
		else
			if ibyteIdx and obyteIdx then
				local cols = {}
				for word in line:gmatch("%S+") do
					table.insert(cols, word)
				end
				local iface = cols[1] or ""
				if iface:match("^en%d") then
					local ib = tonumber(cols[ibyteIdx]) or 0
					local ob = tonumber(cols[obyteIdx]) or 0
					totalIn = totalIn + ib
					totalOut = totalOut + ob
				end
			end
		end
	end

	local now = hs.timer.secondsSinceEpoch()
	local result = "↓ –   ↑ –"

	if netPrev and netPrevTime then
		local dt = now - netPrevTime
		if dt > 0 then
			local dIn = (totalIn - netPrev.inp) / dt
			local dOut = (totalOut - netPrev.out) / dt

			local function fmtRate(bps)
				if bps >= 1024 * 1024 then
					return string.format("%.1f MB/s", bps / 1024 / 1024)
				elseif bps >= 1024 then
					return string.format("%.0f KB/s", bps / 1024)
				else
					return string.format("%.0f B/s", bps)
				end
			end

			result = string.format("↓ %s  ↑ %s", fmtRate(dIn), fmtRate(dOut))
		end
	end

	netPrev = { inp = totalIn, out = totalOut }
	netPrevTime = now

	return result
end

-----------------------------------------------------------------------
-- TEXT BUILDING
-----------------------------------------------------------------------

local function buildText()
	local stats, topProcs = gatherStats()
	local lines = {}

	-- header
	table.insert(lines, string.format("%-13s %5s  %10s  %3s", "APP", "CPU", "MEM", " # "))
	table.insert(lines, string.rep("─", 38))

	-- app rows
	for _, app in ipairs(TARGET_APPS) do
		local s = stats[app]
		if s.count > 0 then
			table.insert(
				lines,
				string.format("%-13s %4.1f%%  %10s  %3d", app, s.cpu, fmtMem(s.mem), s.count)
			)
		else
			table.insert(
				lines,
				string.format("%-13s %5s  %10s  %3s", app, "–", "offline", "–")
			)
		end
	end

	-- top processes
	table.insert(lines, "")
	table.insert(lines, "TOP PROCESSES")
	for _, p in ipairs(topProcs) do
		local name = p.name
		if #name > 13 then name = name:sub(1, 12) .. "…" end
		table.insert(
			lines,
			string.format("%-13s %4.1f%%  %10s", name, p.cpu, fmtMem(p.mem))
		)
	end

	-- system metrics
	table.insert(lines, "")
	table.insert(lines, string.format("CPU  %-10s  MEM  %s", sysCpu(), sysMem()))
	table.insert(lines, string.format("NET  %s", netThroughput()))

	return table.concat(lines, "\n")
end

-----------------------------------------------------------------------
-- MENUBAR (always-on, click for dropdown)
-----------------------------------------------------------------------

local function buildMenuItems()
	local stats = gatherStats()
	local items = {}

	-- header
	table.insert(items, {
		title = string.format("%-14s %5s  %9s  %2s", "APP", "CPU", "MEM", "#"),
		disabled = true,
		fn = nil,
	})
	table.insert(items, { title = "-" })

	-- app rows
	for _, app in ipairs(TARGET_APPS) do
		local s = stats[app]
		local title
		if s.count > 0 then
			title = string.format("%-14s %4.1f%%  %9s  %2d", app, s.cpu, fmtMem(s.mem), s.count)
		else
			title = string.format("%-14s %5s  %9s  %2s", app, "–", "offline", "–")
		end
		table.insert(items, { title = title, disabled = true })
	end

	table.insert(items, { title = "-" })

	-- system metrics
	table.insert(items, {
		title = string.format("CPU  %s   MEM  %s", sysCpu(), sysMem()),
		disabled = true,
	})
	table.insert(items, {
		title = string.format("NET  %s", netThroughput()),
		disabled = true,
	})

	table.insert(items, { title = "-" })
	if panel then
		table.insert(items, {
			title = "Hide Overlay",
			fn = function()
				M.hideOverlay()
			end,
		})
		local lockTitle = clickThrough and "🔓 Make Draggable" or "🔒 Lock Position (Click-Through)"
		table.insert(items, {
			title = lockTitle,
			fn = function()
				clickThrough = not clickThrough
				hs.settings.set("resourceMonitorClickThrough", clickThrough)
				if panel then
					if clickThrough then
						panel:mouseCallback(nil)
					else
						panel:mouseCallback(dragCallback)
					end
				end
			end,
		})
	else
		table.insert(items, {
			title = "Show Overlay",
			fn = function()
				M.showOverlay()
			end,
		})
	end

	return items
end

function M.startMenubar()
	if menubar then
		return
	end

	menubar = hs.menubar.new()
	menubar:setTitle("📊")
	menubar:setMenu(buildMenuItems)
end

function M.stopMenubar()
	if menubar then
		menubar:delete()
		menubar = nil
	end
end

-----------------------------------------------------------------------
-- OVERLAY (temporary on-screen panel via hotkey)
-----------------------------------------------------------------------

local function calcHeight()
	-- header(2) + apps + blank + "TOP PROCESSES" + top3 + blank + sys(2) + padding
	return PAD_Y + (LINE_H * 2) + (#TARGET_APPS * LINE_H) + LINE_H + LINE_H + (TOP_N * LINE_H) + LINE_H + (LINE_H * 2) + PAD_Y
end

local function overlayFrame()
	local savedPos = hs.settings.get("resourceMonitorPosition")
	local screen = hs.screen.mainScreen():frame()
	local h = calcHeight()
	if savedPos and savedPos.x and savedPos.y then
		return {
			x = savedPos.x,
			y = savedPos.y,
			w = WIDTH,
			h = h,
		}
	end
	return {
		x = screen.x + screen.w - WIDTH - 16,
		y = screen.y + 6,
		w = WIDTH,
		h = h,
	}
end

local function updateOverlay()
	if not panel then
		return
	end
	panel[2].text = buildText()
end

function M.showOverlay()
	if panel then
		return
	end

	local h = calcHeight()
	panel = hs.canvas.new(overlayFrame())

	panel:level(hs.canvas.windowLevels.status)
	panel:behavior({
		hs.canvas.windowBehaviors.canJoinAllSpaces,
		hs.canvas.windowBehaviors.stationary,
	})

	-- background
	panel[1] = {
		type = "rectangle",
		roundedRectRadii = { 10, 10 },
		fillColor = {
			red = 0.08,
			green = 0.08,
			blue = 0.08,
			alpha = 0.78,
		},
		strokeColor = {
			white = 0.25,
			alpha = 0.25,
		},
	}

	-- text
	panel[2] = {
		type = "text",
		frame = {
			x = PAD_X,
			y = PAD_Y,
			w = WIDTH - (PAD_X * 2),
			h = h - (PAD_Y * 2),
		},
		text = "Loading…",
		textFont = FONT,
		textSize = FONT_SIZE,
		textColor = { white = 0.92, alpha = 1 },
	}

	dragCallback = function(_, msg, x, y)
		if msg == "mouseDown" then
			dragging = true
			dragOffset = { x = x, y = y }
		elseif msg == "mouseUp" then
			dragging = false
			local frame = panel:frame()
			hs.settings.set("resourceMonitorPosition", { x = frame.x, y = frame.y })
		elseif msg == "mouseMove" and dragging then
			local pos = hs.mouse.absolutePosition()
			panel:frame({
				x = pos.x - dragOffset.x,
				y = pos.y - dragOffset.y,
				w = WIDTH,
				h = calcHeight(),
			})
		end
	end

	-- drag support
	if not clickThrough then
		panel:mouseCallback(dragCallback)
	end

	panel:show()
	updateOverlay()

	panelTimer = hs.timer.doEvery(UPDATE_INTERVAL, updateOverlay)
end

function M.hideOverlay()
	if panelTimer then
		panelTimer:stop()
		panelTimer = nil
	end
	if panel then
		panel:delete()
		panel = nil
	end
end

--- Toggle the overlay. Hotkey-friendly.
function M.toggle()
	if panel then
		M.hideOverlay()
	else
		M.showOverlay()
	end
end

-----------------------------------------------------------------------
-- AUTO-START menubar
-----------------------------------------------------------------------
M.startMenubar()

return M
