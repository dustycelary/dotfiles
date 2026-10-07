---@diagnostic disable: undefined-global
-- Overlay for the AeroSpace cheat sheet rendered by
-- ~/.config/aerospace/show-keys.sh, which calls
--   open -g "hammerspoon://aerospace-keys?file=<html path>"
-- A webview floats above everything without taking keyboard focus, so
-- AeroSpace can't pull focus back and close it (which is what happens to a
-- Quick Look panel). Esc is grabbed only while the sheet is showing; calling
-- the URL again toggles it off.

local view, escKey

local function close()
	if view then
		view:delete()
		view = nil
	end
	if escKey then
		escKey:delete()
		escKey = nil
	end
end

hs.urlevent.bind("aerospace-keys", function(_, params)
	if view then
		close()
		return
	end
	local f = params.file and io.open(params.file)
	if not f then
		return
	end
	local page = f:read("a")
	f:close()

	local screen = hs.mouse.getCurrentScreen():frame()
	local w, h = math.min(1100, screen.w - 80), math.min(860, screen.h - 80)
	view = hs.webview.new({ x = screen.x + (screen.w - w) / 2, y = screen.y + (screen.h - h) / 2, w = w, h = h })
	view:windowStyle({ "borderless", "nonactivating" })
		:level(hs.drawing.windowLevels.modalPanel)
		:transparent(true)
		:shadow(true)
		:allowTextEntry(false)
		:html(page)
		:show()
	escKey = hs.hotkey.bind({}, "escape", close)
end)
