---@diagnostic disable: undefined-global

hs.window.animationDuration = 0

require("hammer-control.init")

-- agy, antigravity & ollama monitoring
-- Initialize all menu bar items.
-- By default, we start in State 1 (Unified), so masterMenu starts visible, others start hidden.
masterMenu = hs.menubar.new()
agyMenu = hs.menubar.new(false)
appMenu = hs.menubar.new(false)
ollamaMenu = hs.menubar.new(false)

-- Hotkey configuration: Cmd + Alt + Ctrl + M
local toggleModifiers = { "alt", "ctrl" }
local toggleKey = "p"

-- State tracking:
-- 1 = Unified dropdown menu (🛸)
-- 2 = Hidden (Nothing visible)
-- 3 = All visible individually (􀩼 , 🛸, 🦙)
menuBarState = 1

local function updateStatus()
	-- 1. Ask the system directly for all processes (CPU and Command line)
	-- Using the absolute path /bin/ps guarantees Hammerspoon can find it
	local output = hs.execute("/bin/ps x -o %cpu,command")

	-- Safety check: if ps fails entirely
	if not output then
		if menuBarState == 1 then
			masterMenu:setTitle("􀯗 ERR")
			masterMenu:setMenu({
				{ title = "Error retrieving process statuses", disabled = true },
			})
		elseif menuBarState == 3 then
			agyMenu:setTitle("􀩼 ERR")
			appMenu:setTitle("􀯗 ERR")
			ollamaMenu:setTitle("🦙ERR")
		end
		return
	end

	local agyCpu = 0
	local agyRunning = false

	local appCpu = 0
	local appRunning = false

	local ollamaCpu = 0
	local ollamaRunning = false

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
				-- Check for Ollama
				if string.find(string.lower(line), "ollama") then
					ollamaCpu = ollamaCpu + cpu
					ollamaRunning = true
				end
			end
		end
	end

	-- 3. Determine individual statuses
	local agyStatus = "OFF"
	if agyRunning then
		if agyCpu > 10.0 then
			agyStatus = string.format("%.1f%%", agyCpu)
		else
			agyStatus = "IDLE"
		end
	end

	local appStatus = "OFF"
	if appRunning then
		if appCpu > 10.0 then
			appStatus = string.format("%.1f%%", appCpu)
		else
			appStatus = "IDLE"
		end
	end

	local ollamaStatus = "OFF"
	if ollamaRunning then
		if ollamaCpu > 10.0 then
			ollamaStatus = string.format("%.1f%%", ollamaCpu)
		else
			ollamaStatus = "IDLE"
		end
	end

	-- 4. Apply status changes based on current state
	if menuBarState == 1 then
		local anyWarning = (agyRunning and agyCpu > 10.0)
			or (appRunning and appCpu > 10.0)
			or (ollamaRunning and ollamaCpu > 10.0)
		if anyWarning then
			masterMenu:setTitle("􀯗 ")
		else
			masterMenu:setTitle("􀩼 ")
		end

		masterMenu:setMenu({
			{ title = "􀩼  CLI: " .. agyStatus, disabled = true },
			{ title = "􀯗 App: " .. appStatus, disabled = true },
			{ title = "🦙 Ollama: " .. ollamaStatus, disabled = true },
			{ title = "-" },
			{ title = "Force Refresh", fn = updateStatus },
		})
	elseif menuBarState == 3 then
		-- CLI
		if not agyRunning then
			agyMenu:setTitle("􀩼 OFF")
		elseif agyCpu > 10.0 then
			agyMenu:setTitle("􀩼 " .. string.format("%.1f", agyCpu) .. "%")
		else
			agyMenu:setTitle("􀩼 IDLE")
		end

		-- App
		if not appRunning then
			appMenu:setTitle("􀯗 OFF")
		elseif appCpu > 10.0 then
			appMenu:setTitle("􀯗 " .. string.format("%.1f", appCpu) .. "%")
		else
			appMenu:setTitle("􀯗 IDLE")
		end

		-- Ollama
		if not ollamaRunning then
			ollamaMenu:setTitle("🦙OFF")
		elseif ollamaCpu > 10.0 then
			ollamaMenu:setTitle("🦙" .. string.format("%.1f", ollamaCpu) .. "%")
		else
			ollamaMenu:setTitle("🦙IDLE")
		end
	end
end

-- Helper to apply the current visibility state to all menu items
local function applyMenuBarState()
	if menuBarState == 1 then
		-- Unified
		masterMenu:returnToMenuBar()
		agyMenu:removeFromMenuBar()
		appMenu:removeFromMenuBar()
		ollamaMenu:removeFromMenuBar()
	elseif menuBarState == 2 then
		-- Hidden (Nothing)
		masterMenu:removeFromMenuBar()
		agyMenu:removeFromMenuBar()
		appMenu:removeFromMenuBar()
		ollamaMenu:removeFromMenuBar()
	elseif menuBarState == 3 then
		-- All Visible
		masterMenu:removeFromMenuBar()
		agyMenu:returnToMenuBar()
		appMenu:returnToMenuBar()
		ollamaMenu:returnToMenuBar()
	end
	-- Refresh title/menus immediately
	updateStatus()
end

-- Register the Hotkey to cycle state
hs.hotkey.bind(toggleModifiers, toggleKey, function()
	menuBarState = menuBarState + 1
	if menuBarState > 3 then
		menuBarState = 1
	end
	applyMenuBarState()

	local stateNames = {
		[1] = "Unified Menu Bar Item",
		[2] = "Hidden Menu Bar Items",
		[3] = "All Menu Bar Items Visible",
	}
	hs.alert.show("Menu Bar: " .. stateNames[menuBarState])
end)

-- Run immediately on startup
updateStatus()

-- Check every 3 seconds
statusTimer = hs.timer.doEvery(3, updateStatus)
