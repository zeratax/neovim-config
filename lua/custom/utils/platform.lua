--- Platform utilities module
-- @module platform
local M = {}

--- Detects the Linux distribution by reading the `/etc/os-release` file.
-- This function attempts to open `/etc/os-release` to read the system's distribution name.
-- It returns `nil` if the file cannot be read (e.g., on non-Linux systems) or if the `NAME` field is not found.
---@return string|nil # The name of the Linux distribution, or `nil` if not found or on non-Linux systems.
function M.getLinuxDistro()
  local file = io.open('/etc/os-release', 'r')
  if not file then
    return nil
  end

  for line in file:lines() do
    if line:match '^NAME=' then
      return line:match '^NAME=(.*)'
    end
  end

  file:close()
  return nil
end

return M
