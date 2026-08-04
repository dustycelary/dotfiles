local isLaunching = false
local activeViewerCanvas = nil
local activeViewerTimer = nil
local activeViewerFadeTimer = nil

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

			-- Run/attach to the existing tmux session instead of opening Ghostty.
			hs.execute("/opt/homebrew/bin/tmux new-session -A -s sp")
		else
			-- No tracked Ghostty window, just launch Ghostty once into the session.
			hs.execute("open -na Ghostty --args -e /opt/homebrew/bin/tmux new-session -A -s sp")
		end
	end,

	spotifyGet = function(key)
		local cmd = "/opt/homebrew/bin/spotify_player get key " .. key
		local output, status, type_ret, rc = hs.execute(cmd)

		if not output or output == "" then
			hs.alert.show("No response from Spotify Player for key: " .. key, 3)
			return
		end

		local success, result = pcall(function()
			local data = hs.json.decode(output)
			if not data then
				error("Could not decode JSON response.")
			end

			local title = key:gsub("-", " "):gsub("^%l", string.upper)
			local lines = { "🎧  " .. title:upper() .. "\n" }

			if key == "playback" then
				if not data.item then
					table.insert(lines, "Nothing is playing.")
				else
					local track = data.item.name or "Unknown Track"
					local artists = {}
					for _, a in ipairs(data.item.artists or {}) do
						if a.name then
							table.insert(artists, a.name)
						end
					end
					local artist = table.concat(artists, ", ")
					if artist == "" then
						artist = "Unknown Artist"
					end
					local album = data.item.album and data.item.album.name or "Unknown Album"
					local is_playing = data.is_playing and "▶ Playing" or "⏸ Paused"
					local progress = math.floor((data.progress_ms or 0) / 1000)
					local duration = math.floor((data.item.duration_ms or 0) / 1000)
					local progress_str = string.format(
						"%d:%02d / %d:%02d",
						math.floor(progress / 60),
						progress % 60,
						math.floor(duration / 60),
						duration % 60
					)

					table.insert(
						lines,
						string.format(
							"%s\n🎵 %s\n👤 %s\n💿 %s\n⏱ %s",
							is_playing,
							track,
							artist,
							album,
							progress_str
						)
					)
				end
			elseif key == "devices" then
				if type(data) ~= "table" then
					error("Invalid devices data format.")
				end
				for _, dev in ipairs(data) do
					local name = dev.name or "Unknown Device"
					local dev_type = dev.type or "Unknown Type"
					local vol = dev.volume_percent or 0
					local active = dev.is_active and " [Active]" or ""
					table.insert(lines, string.format("• %s (%s) - Vol: %d%%%s", name, dev_type, vol, active))
				end
				if #lines == 1 then
					table.insert(lines, "No devices found.")
				end
			elseif key == "queue" then
				local tracks = nil
				if type(data) == "table" then
					tracks = data.queue or data
				end
				if type(tracks) ~= "table" then
					error("Invalid queue data format.")
				end

				local count = 0
				for _, _ in ipairs(tracks) do
					count = count + 1
				end

				for i, track in ipairs(tracks) do
					if i > 10 then
						table.insert(lines, string.format("... and %d more", count - 10))
						break
					end
					local track_name = track.name or "Unknown Track"
					local artists = {}
					for _, a in ipairs(track.artists or {}) do
						if a.name then
							table.insert(artists, a.name)
						end
					end
					local artist = table.concat(artists, ", ")
					if artist == "" then
						artist = "Unknown Artist"
					end
					table.insert(lines, string.format("%d. %s - %s", i, track_name, artist))
				end
				if count == 0 then
					table.insert(lines, "Queue is empty.")
				end
			elseif key == "user-playlists" then
				if type(data) ~= "table" then
					error("Invalid playlists data format.")
				end
				for i, pl in ipairs(data) do
					if i > 12 then
						table.insert(lines, string.format("... and %d more", #data - 12))
						break
					end
					local name = pl.name or "Unnamed Playlist"
					table.insert(lines, string.format("• %s", name))
				end
				if #lines == 1 then
					table.insert(lines, "No playlists found.")
				end
			elseif key == "user-liked-tracks" or key == "user-top-tracks" then
				if type(data) ~= "table" then
					error("Invalid tracks data format.")
				end
				for i, track in ipairs(data) do
					if i > 12 then
						table.insert(lines, string.format("... and %d more", #data - 12))
						break
					end
					local track_name = track.name or "Unknown Track"
					local artists = {}
					for _, a in ipairs(track.artists or {}) do
						if a.name then
							table.insert(artists, a.name)
						end
					end
					local artist = table.concat(artists, ", ")
					if artist == "" then
						artist = "Unknown Artist"
					end
					table.insert(lines, string.format("%d. %s - %s", i, track_name, artist))
				end
				if #lines == 1 then
					table.insert(lines, "No tracks found.")
				end
			elseif key == "user-saved-albums" then
				if type(data) ~= "table" then
					error("Invalid albums data format.")
				end
				for i, album in ipairs(data) do
					if i > 12 then
						table.insert(lines, string.format("... and %d more", #data - 12))
						break
					end
					local name = album.name or "Unknown Album"
					local artists = {}
					for _, a in ipairs(album.artists or {}) do
						if a.name then
							table.insert(artists, a.name)
						end
					end
					local artist = table.concat(artists, ", ")
					if artist == "" then
						artist = "Unknown Artist"
					end
					table.insert(lines, string.format("• %s - %s", name, artist))
				end
				if #lines == 1 then
					table.insert(lines, "No albums found.")
				end
			elseif key == "user-followed-artists" then
				if type(data) ~= "table" then
					error("Invalid artists data format.")
				end
				for i, artist in ipairs(data) do
					if i > 12 then
						table.insert(lines, string.format("... and %d more", #data - 12))
						break
					end
					local name = artist.name or "Unknown Artist"
					table.insert(lines, string.format("• %s", name))
				end
				if #lines == 1 then
					table.insert(lines, "No followed artists found.")
				end
			else
				table.insert(lines, tostring(output):sub(1, 500))
			end

			return table.concat(lines, "\n")
		end)

		local displayText
		if success then
			displayText = result
		else
			displayText = "❌ Spotify Player Error for '"
				.. key
				.. "':\n"
				.. tostring(result)
				.. "\n\nRaw output snippet:\n"
				.. tostring(output):sub(1, 200)
		end

		hs.alert.show(displayText, {
			strokeWidth = 2,
			strokeColor = { white = 0.5, alpha = 0.8 },
			fillColor = { white = 0.08, alpha = 0.95 },
			textColor = { white = 0.95, alpha = 1 },
			textFont = "SF Mono",
			textSize = 15,
			radius = 10,
			padding = 16,
		}, hs.screen.mainScreen(), 6)
	end,
}

return helpers
