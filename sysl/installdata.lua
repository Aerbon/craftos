local args = {...}

local options
if type(args[1]) == "table" then
  options = args
end

local files = {}
local deps = {}
-- These go in the package's own folder
files.internal = {}
-- These go in the programs folder
files.programs = {
  ["sysl.lua"] = "programs/sysl.lua"
}
-- These go in the lib folder
files.lib = {}
-- These go to an absolute path
files.other = {}

-- It makes sense to support running a function before and after packages have been updated.
local function preInstall() end
local function postInstall() end

return {
  files = files,
  deps = deps,
  preInstall = preInstall,
  postInstall = postInstall,
}