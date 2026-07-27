local isLaunching = false
local activeViewerCanvas = nil
local activeViewerTimer = nil
local activeViewerFadeTimer = nil

local function getAllGhosttyWindows()
	local windows = {}
	for _, app in ipairs(hs.application.runningApplications()) do
		if app:name() == "Ghostty" then
			for _, w in ipairs(app:allWindows()) do
				windows[w:id()] = w
			end
		end
	end
	return windows
end

local helpers = {
	openAlfredClipboard = function()
		local openAlfredClipboard = [[
                        tell application id "com.runningwithcrayons.Alfred" to search "clipboard" ]]
		hs.osascript.applescript(openAlfredClipboard)

		-- Wait 0.2 seconds (adjust as needed), then press Enter
		hs.timer.doAfter(0.2, function()
			hs.eventtap.keyStroke({}, "return")
		end)
	end,

	showResourceViewer = function()
		-- Customize applications to monitor here
		local targetApps = { "Ghostty", "Safari", "Ollama", "Hammerspoon", "Docker", "Slack", "Code", "Finder" }

		local output = hs.execute("ps -eo %cpu,rss,comm")
		local stats = {}

		for _, app in ipairs(targetApps) do
			stats[app] = { cpu = 0, mem = 0, count = 0 }
		end

		for line in output:gmatch("[^\r\n]+") do
			local cpuStr, rssStr, comm = line:match("%s*([%d%.]+)%s+(%d+)%s+(.+)")
			local cpu = tonumber(cpuStr)
			local rss = tonumber(rssStr)
			if cpu and rss and comm then
				for _, app in ipairs(targetApps) do
					if comm:lower():find(app:lower(), 1, true) then
						stats[app].cpu = stats[app].cpu + cpu
						stats[app].mem = stats[app].mem + rss
						stats[app].count = stats[app].count + 1
					end
				end
			end
		end

		local lines = { "📊  APPLICATION RESOURCE VIEWER", "" }
		local totalCpu = 0
		local totalMem = 0
		for _, app in ipairs(targetApps) do
			local s = stats[app]
			if s.count > 0 then
				totalCpu = totalCpu + s.cpu
				totalMem = totalMem + s.mem
				local memStr = string.format("%.1f MB", s.mem / 1024)
				if s.mem >= 1024 * 1024 then
					memStr = string.format("%.2f GB", s.mem / (1024 * 1024))
				end
				table.insert(
					lines,
					string.format("%-14s  CPU: %5.1f%%   RAM: %8s  (%d proc)", app, s.cpu, memStr, s.count)
				)
			else
				table.insert(lines, string.format("%-14s  -- offline / not running --", app))
			end
		end

		table.insert(lines, "")
		local totalMemStr = string.format("%.1f MB", totalMem / 1024)
		if totalMem >= 1024 * 1024 then
			totalMemStr = string.format("%.2f GB", totalMem / (1024 * 1024))
		end
		table.insert(lines, string.format("TOTAL TRACKED    CPU: %5.1f%%   RAM: %8s", totalCpu, totalMemStr))

		-- Clean up any existing viewer overlays
		if activeViewerTimer then
			activeViewerTimer:stop()
			activeViewerTimer = nil
		end
		if activeViewerFadeTimer then
			activeViewerFadeTimer:stop()
			activeViewerFadeTimer = nil
		end
		if activeViewerCanvas then
			activeViewerCanvas:delete()
			activeViewerCanvas = nil
		end

		-- Set up canvas parameters
		local screen = hs.screen.mainScreen():frame()
		local canvasW = 540
		local canvasH = #lines * 22 + 20
		local canvasX = screen.x + (screen.w - canvasW) / 2
		local canvasY = screen.y + 40 -- position slightly below the top menu bar

		local canvas = hs.canvas.new({
			x = canvasX,
			y = canvasY,
			w = canvasW,
			h = canvasH,
		})
		canvas:level(hs.canvas.windowLevels.status)
		canvas:behavior({
			hs.canvas.windowBehaviors.canJoinAllSpaces,
			hs.canvas.windowBehaviors.stationary,
		})

		-- Background element
		canvas[1] = {
			type = "rectangle",
			roundedRectRadii = { 12, 12 },
			fillColor = { white = 0.08, alpha = 0.92 },
			strokeColor = { white = 0.4, alpha = 0.8 },
			strokeWidth = 2,
		}

		-- Text element
		canvas[2] = {
			type = "text",
			frame = {
				x = 20,
				y = 10,
				w = canvasW - 40,
				h = canvasH - 20,
			},
			text = table.concat(lines, "\n"),
			textFont = "SF Mono",
			textSize = 15,
			textColor = { white = 0.95, alpha = 1 },
		}
		canvas:show()
		activeViewerCanvas = canvas

		-- Smooth fade out after 3.7 seconds (total 4.0 seconds duration)
		local initialAlpha = 0.92
		activeViewerTimer = hs.timer.doAfter(3.7, function()
			local steps = 10
			local step = 0
			activeViewerFadeTimer = hs.timer.doEvery(0.03, function(timer)
				step = step + 1
				if step >= steps then
					timer:stop()
					activeViewerFadeTimer = nil
					if activeViewerCanvas == canvas then
						canvas:delete()
						activeViewerCanvas = nil
					end
				else
					if activeViewerCanvas == canvas then
						canvas:alpha(initialAlpha * (1 - step / steps))
					end
				end
			end)
		end)
	end,

	launchAppMonitor = function()
		local ghostty = hs.application.find("Ghostty")
		if not ghostty then
			hs.application.launchOrFocus("Ghostty")
			ghostty = hs.application.find("Ghostty")
		end

		if ghostty then
			ghostty:activate()
			local ok = ghostty:selectMenuItem({ "File", "New Window" })
			if not ok then
				hs.eventtap.keyStroke({ "cmd" }, "n", 0, ghostty)
			end

			hs.timer.doAfter(0.2, function()
				local win = hs.window.focusedWindow()
				if win and win:application():bundleID() == ghostty:bundleID() then
					hs.eventtap.keyStrokes("~/.hammerspoon/scripts/app_monitor.sh")
					hs.timer.doAfter(1, function()
						hs.eventtap.keyStroke({}, "return")
					end)
					local screenFrame = win:screen():frame()
					win:setFrame({ x = screenFrame.x, y = screenFrame.y, w = 320, h = 270 })
				end
			end)
		end
	end,

	openTmuxSpGhostty = function()
		if isLaunching then
			return
		end

		local storedId = hs.settings.get("tmuxSpGhosttyWindowId")
		local win = storedId and hs.window.get(storedId)
		if win then
			win:focus()
		else
			if storedId then
				hs.settings.clear("tmuxSpGhosttyWindowId")
			end
			isLaunching = true
			local oldWindows = {}
			for id, _ in pairs(getAllGhosttyWindows()) do
				oldWindows[id] = true
			end

			hs.execute("open -na Ghostty --args -e /opt/homebrew/bin/tmux new-session -A -s sp")

			local attempts = 0
			local function findNewWindow()
				local currentWindows = getAllGhosttyWindows()
				for id, w in pairs(currentWindows) do
					if not oldWindows[id] then
						hs.settings.set("tmuxSpGhosttyWindowId", id)
						isLaunching = false
						return
					end
				end
				attempts = attempts + 1
				if attempts < 30 then
					hs.timer.doAfter(0.1, findNewWindow)
				else
					isLaunching = false
				end
			end
			hs.timer.doAfter(0.1, findNewWindow)
		end
	end,
}

return helpers
