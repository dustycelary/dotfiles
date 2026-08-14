local time = require("hammer-control/time")

local M = {}
local BLOCK_FILE = ""
local START_IN_PROGRESS = false
local SELFCONTROL_CLI = "/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli"

local function isSelfControlRunning()
  local output = hs.execute(SELFCONTROL_CLI .. " is-running 2>&1")
  return output and string.match(output, "YES%s*$") ~= nil
end

local function selfControlCallback(exit_code, std_out, std_error)
  START_IN_PROGRESS = false

  if exit_code == 0 then
    print("SelfControl started")
    hs.alert.show("SelfControl started", 2)
    return
  end

  local error_output = (std_out or "") .. (std_error or "")
  if string.match(error_output, "Blocklist is empty, or block does not end in the future") then
    local block_file_attributes = hs.fs.attributes(BLOCK_FILE)
    if not (block_file_attributes and block_file_attributes["mode"] == "file") then
      error_output = "Blocklist file " .. BLOCK_FILE .. " does not exist"
    else
      error_output = "End date ends in the past"
    end
  elseif string.match(error_output, "Blocklist could not be read from file") then
    error_output = "Blocklist file " .. BLOCK_FILE .. " has an error in it. Save the blocklist again."
  elseif string.match(error_output, "Block is already running") then
    print("SelfControl is already running")
    return
  end

  print("SelfControl failed to start (exit " .. tostring(exit_code) .. "): " .. error_output)
  hs.alert.show("SelfControl failed to start; check the Hammerspoon Console", 4)
end

function M.start()
  if START_IN_PROGRESS or isSelfControlRunning() then
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
  local uid = hs.execute("/usr/bin/id -u"):gsub("%s+$", "")
  local selfcontrol_task = hs.task.new("/usr/bin/sudo", selfControlCallback, {
    "-S", "-p", "", SELFCONTROL_CLI, "--uid", uid, "start",
    "--enddate", end_time, "--blocklist", blocklist_path,
  })
  selfcontrol_task:setInput(password .. "\n")
  START_IN_PROGRESS = true
  if not selfcontrol_task:start() then
    START_IN_PROGRESS = false
    error("Couldn't start SelfControl task")
  end
end

function M.run()
  M.start()
end

return M
