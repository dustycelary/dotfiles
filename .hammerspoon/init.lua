---@diagnostic disable: undefined-global

hs.window.animationDuration = 0

require("hammer-control.init")

-- agy monitoring
-- Create a new space in the macOS menu bar
agyMenu = hs.menubar.new()

local function updateAgyStatus()
	-- 1. Ask the system directly for all processes (CPU and Command line)
	-- Using the absolute path /bin/ps guarantees Hammerspoon can find it
	local output = hs.execute("/bin/ps x -o %cpu,command")

	-- Safety check: if ps fails entirely
	if not output then
		agyMenu:setTitle("🤖 ERR")
		return
	end

	local totalCpu = 0
	local isRunning = false

	-- 2. Loop through every single line of the output
	for line in string.gmatch(output, "[^\r\n]+") do
		-- 3. Look for the word "agy" in the command, but ignore our own ps command
		if string.find(line, "agy") and not string.find(line, "ps x") then
			-- Extract the number at the very start of the line (the CPU percentage)
			local cpuStr = string.match(line, "^%s*([%d%.]+)")

			if cpuStr then
				totalCpu = totalCpu + tonumber(cpuStr)
				isRunning = true
			end
		end
	end

	-- 4. Update the menu bar
	if not isRunning then
		agyMenu:setTitle("🤖 OFF")
	elseif totalCpu > 10.0 then
		-- High CPU: Show warning
		agyMenu:setTitle("🤖 ⚠ " .. string.format("%.1f", totalCpu) .. "%")
	else
		-- Running but idle
		agyMenu:setTitle("🤖 IDLE")
	end
end

-- Run immediately on startup
updateAgyStatus()

-- Check every 3 seconds
agyTimer = hs.timer.doEvery(3, updateAgyStatus)
