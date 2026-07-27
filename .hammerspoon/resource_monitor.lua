local M = {}

-----------------------------------------------------------------------
-- CONFIG
-----------------------------------------------------------------------

local TARGET_APPS = { "Ghostty", "Safari", "Ollama", "Hammerspoon", "Docker" }

local WIDTH = 320
local PAD_X = 10
local PAD_Y = 6
local LINE_H = 17
local FONT_SIZE = 11.5
local FONT = "SF Mono"
local UPDATE_INTERVAL = 2

local panel = nil
local timer = nil
local dragging = false
local dragOffset = nil

-----------------------------------------------------------------------
-- HELPERS
-----------------------------------------------------------------------

local function calcHeight()
	-- header + separator + app rows + blank + 3 system rows + padding
	return PAD_Y + (LINE_H * 2) + (#TARGET_APPS * LINE_H) + LINE_H + (LINE_H * 3) + PAD_Y
end

local function frame()
	local screen = hs.screen.mainScreen():frame()

	return {
		x = screen.x + 6,
		y = screen.y + 6,
		w = WIDTH,
		h = calcHeight(),
	}
end

--- Gather per-app CPU, RSS, and process count from `ps`.
local function gatherStats()
	local output = hs.execute("ps -eo %cpu,rss,comm")
	local stats = {}

	for _, app in ipairs(TARGET_APPS) do
		stats[app] = { cpu = 0, mem = 0, count = 0 }
	end

	for line in output:gmatch("[^\r\n]+") do
		local cpuStr, rssStr, comm = line:match("%s*([%d%.]+)%s+(%d+)%s+(.+)")
		local cpu = tonumber(cpuStr)
		local rss = tonumber(rssStr)

		if cpu and rss and comm then
			for _, app in ipairs(TARGET_APPS) do
				if comm:lower():find(app:lower(), 1, true) then
					stats[app].cpu = stats[app].cpu + cpu
					stats[app].mem = stats[app].mem + rss
					stats[app].count = stats[app].count + 1
				end
			end
		end
	end

	return stats
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
	local ok, vm = pcall(function()
		return hs.host.vmStat()
	end)
	if not ok or not vm then
		return "–"
	end
	local page = vm.pageSize or 4096
	local used = ((vm.activeCount or 0) + (vm.inactiveCount or 0) + (vm.wireCount or 0)) * page
	local total = hs.host.vmStat().memSize
	if total and total > 0 then
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
			-- find column indices from header
			local cols = {}
			for word in line:gmatch("%S+") do
				table.insert(cols, word)
			end
			for i, col in ipairs(cols) do
				if col == "Ibytes" then ibyteIdx = i end
				if col == "Obytes" then obyteIdx = i end
			end
			headerParsed = true
		else
			if ibyteIdx and obyteIdx then
				local cols = {}
				for word in line:gmatch("%S+") do
					table.insert(cols, word)
				end
				local iface = cols[1] or ""
				-- only count en* and lo* interfaces
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

local function buildText()
	local stats = gatherStats()
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

	-- system metrics
	table.insert(lines, "")
	table.insert(lines, string.format("CPU  %-10s  MEM  %s", sysCpu(), sysMem()))
	table.insert(lines, string.format("NET  %s", netThroughput()))

	return table.concat(lines, "\n")
end

local function update()
	if not panel then
		return
	end

	local h = calcHeight()
	panel[2].text = buildText()

	-- resize canvas if height changed
	local f = panel:frame()
	if f.h ~= h then
		panel:frame({ x = f.x, y = f.y, w = WIDTH, h = h })
		panel[2].frame = { x = PAD_X, y = PAD_Y, w = WIDTH - (PAD_X * 2), h = h - (PAD_Y * 2) }
	end
end

-----------------------------------------------------------------------
-- PUBLIC
-----------------------------------------------------------------------

function M.show()
	if panel then
		return
	end

	local h = calcHeight()
	panel = hs.canvas.new(frame())

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
			alpha = 0.65,
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

	-- drag support
	panel:mouseCallback(function(_, msg, x, y)
		if msg == "mouseDown" then
			dragging = true
			dragOffset = { x = x, y = y }
		elseif msg == "mouseUp" then
			dragging = false
		elseif msg == "mouseMove" and dragging then
			local pos = hs.mouse.absolutePosition()
			panel:frame({
				x = pos.x - dragOffset.x,
				y = pos.y - dragOffset.y,
				w = WIDTH,
				h = calcHeight(),
			})
		end
	end)

	panel:show()
	update()
	timer = hs.timer.doEvery(UPDATE_INTERVAL, update)
end

function M.hide()
	if timer then
		timer:stop()
		timer = nil
	end

	if panel then
		panel:delete()
		panel = nil
	end
end

function M.toggle()
	if panel then
		M.hide()
	else
		M.show()
	end
end

return M
