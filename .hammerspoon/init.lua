---@diagnostic disable: undefined-global
---

hs.window.animationDuration = 0

-- local Hammerflow = hs.loadSpoon("Hammerflow")
hs.loadSpoon("Hammerflow")

spoon.Hammerflow.registerFormat({
	atScreenEdge = 2, -- 0 = Top, 1 = Bottom, 2 = Left, (Omit for centered)
	atScreenEdgeDistance = 30,
	--
	strokeWidth = 4,

	-- Visual Styling Options
	strokeColor = { white = 1, alpha = 0.8 },
	fillColor = { white = 0.1, alpha = 0.9 },
	textColor = { white = 1, alpha = 1 },
	textFont = "SF Mono",
	textSize = 18,
	-- textSize = 13,
	radius = 10,
	-- padding = 8,
	padding = 14,
})
spoon.Hammerflow.atScreenEdge = 1

-- Hammerflow.loadFirstValidTomlFile({ "hammerflow.toml" })

-- spoon.Hammerflow.atScreenEdge = 2
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
}
spoon.Hammerflow.registerFunctions(helpers)

spoon.Hammerflow.loadFirstValidTomlFile({
	"home.toml",
	"work.toml",
	"Spoons/Hammerflow.spoon/keymap.toml",
})
-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
	hs.loadSpoon("ReloadConfiguration")
	-- set any paths for auto reload
	-- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
	spoon.ReloadConfiguration:start()
end

require("hammer-control.init")
