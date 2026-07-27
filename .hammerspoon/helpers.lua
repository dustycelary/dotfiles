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

		hs.alert.show(table.concat(lines, "\n"), {
			textFont = "SF Mono",
			textSize = 15,
			radius = 12,
			atScreenEdge = 0,
			strokeWidth = 2,
			fillColor = { white = 0.08, alpha = 0.92 },
			strokeColor = { white = 0.4, alpha = 0.8 },
			textColor = { white = 0.95, alpha = 1 },
		}, 4)
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
}

return helpers
