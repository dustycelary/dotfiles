---@diagnostic disable: undefined-global

hs.window.animationDuration = 0

hs.loadSpoon("Hammerflow")

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
	"Spoons/Hammerflow.spoon/sample.toml",
})
-- optionally respect auto_reload setting in the toml config.
if spoon.Hammerflow.auto_reload then
	hs.loadSpoon("ReloadConfiguration")
	-- set any paths for auto reload
	-- spoon.ReloadConfiguration.watch_paths = {hs.configDir, "~/path/to/my/configs/"}
	spoon.ReloadConfiguration:start()
end

require("hammer-control.init")
