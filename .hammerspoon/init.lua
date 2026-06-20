---@diagnostic disable: undefined-global

hs.window.animationDuration = 0

require("hammer-control.init")

-- agy & antigravity monitoring
-- Create new spaces in the macOS menu bar
agyMenu = hs.menubar.new()
appMenu = hs.menubar.new()

local function updateStatus()
	-- 1. Ask the system directly for all processes (CPU and Command line)
	-- Using the absolute path /bin/ps guarantees Hammerspoon can find it
	local output = hs.execute("/bin/ps x -o %cpu,command")

	-- Safety check: if ps fails entirely
	if not output then
		agyMenu:setTitle("🤖 ERR")
		appMenu:setTitle("🛸 ERR")
		return
	end

	local agyCpu = 0
	local agyRunning = false
	
	local appCpu = 0
	local appRunning = false

	-- 2. Loop through every single line of the output
	for line in string.gmatch(output, "[^\r\n]+") do
		if not string.find(line, "ps x") then
			local cpuStr = string.match(line, "^%s*([%d%.]+)")
			if cpuStr then
				local cpu = tonumber(cpuStr)
				-- Check for CLI
				if string.find(line, "agy") then
					agyCpu = agyCpu + cpu
					agyRunning = true
				end
				-- Check for App
				if string.find(string.lower(line), "antigravity") then
					appCpu = appCpu + cpu
					appRunning = true
				end
			end
		end
	end

	-- 3. Update the menu bars
	-- CLI
	if not agyRunning then
		agyMenu:setTitle("🤖 OFF")
	elseif agyCpu > 10.0 then
		agyMenu:setTitle("🤖 ⚠ " .. string.format("%.1f", agyCpu) .. "%")
	else
		agyMenu:setTitle("🤖 IDLE")
	end

	-- App
	if not appRunning then
		appMenu:setTitle("🛸 OFF")
	elseif appCpu > 10.0 then
		appMenu:setTitle("🛸 ⚠ " .. string.format("%.1f", appCpu) .. "%")
	else
		appMenu:setTitle("🛸 IDLE")
	end
end

-- Run immediately on startup
updateStatus()

-- Check every 3 seconds
statusTimer = hs.timer.doEvery(3, updateStatus)
