hs.application.enableSpotlightForNameSearches(true)
local selfcontrol = require("hammer-control/selfcontrol")

-- Check frequently enough that a scheduled block starts promptly. Each check
-- reads the real local clock, so sleeping or timer drift cannot skew the time.
SELFCONTROL_TIMER = hs.timer.new(15, selfcontrol.run, true)
SELFCONTROL_TIMER:start()

-- system event tracker
SYSTEM_WATCHER = hs.caffeinate.watcher.new(function(event_type)
  if event_type == hs.caffeinate.watcher.systemDidWake
    or event_type == hs.caffeinate.watcher.screensDidWake
    or event_type == hs.caffeinate.watcher.screensDidUnlock
    or event_type == hs.caffeinate.watcher.sessionDidBecomeActive then
    selfcontrol.start()
  end
end)
SYSTEM_WATCHER:start()

selfcontrol.start()
