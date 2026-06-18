local time = require("hammer-control/time")

local M = {}
local BLOCK_FILE = ""

local function isSelfControlRunning()
  local output = hs.execute("defaults read org.eyebeam.SelfControl BlockIsRunning 2>&1")
  return string.match(output, "^1")
end

local function selfControlCallback(exit_code, _, std_error)
  if exit_code == 0 then
    print("SelfControl started")
    hs.alert.show("SelfControl started", 2)
  elseif string.match(std_error, "Blocklist is empty, or block does not end in the future") then
    local block_file_attributes = hs.fs.attributes(BLOCK_FILE)
    if not (block_file_attributes and block_file_attributes["mode"] == "file") then
      error("Blocklist file " .. BLOCK_FILE .. " does not exist")
    else
      error("End date ends in the past")
    end
  elseif string.match(std_error, "Blocklist could not be read from file") then
    error("Blocklist file " .. BLOCK_FILE .. " has an error in it. Save the blocklist again.")
  elseif string.match(std_error, "Block is already running") then
    print("SelfControl is already running")
  end
end

function M.start()
  if isSelfControlRunning() then
    return
  end

  local schedule = time.getSchedule()
  if not (schedule and schedule.end_time and schedule.blocklist) then
    return
  end

  local end_time = schedule.end_time
  BLOCK_FILE = schedule.blocklist
  if not (end_time and BLOCK_FILE) then
    return
  end

  local password = hs.execute("security find-generic-password -a $(whoami) -s hammer-control -w 2>&1")
  password = password:gsub("%s+$", "") -- strip trailing newline
  if not password or password == "" then
    error("hammer-control password not found in keychain")
    return
  end

  local blocklist_path = hs.fs.pathToAbsolute(BLOCK_FILE)
  -- Run selfcontrol-cli under sudo -S so it reads the password from stdin,
  -- bypassing the SMJobBless GUI prompt entirely.
  local cmd = string.format(
    "echo %q | sudo -S /Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli start --enddate %q --blocklist %q 2>&1",
    password, end_time, blocklist_path
  )

  local selfcontrol_task = hs.task.new("/bin/bash", selfControlCallback, {"-c", cmd})
  if not selfcontrol_task:start() then
    error("Couldn't start SelfControl task")
  end
end

function M.run()
  time.incrementTime()
  M.start()
end

return M
