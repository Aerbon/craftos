local args = {...}

local options
if type(args[1]) == "table" then
  options = args
end

local urlprefix = "https://raw.githubusercontent.com/Aerbon/craftos/master/pkgmanager/"

local files = {}
local deps = {}
-- These go in the package's own folder
files.internal = {}
-- These go in the programs folder
files.programs = {
  -- Target = Source
  ["pkgman.lua"] = "programs/pkgman.lua"
}
-- These go in the lib folder
files.lib = {}
-- These go to an absolute path
files.other = {}

if options.sysl then
  files.other["/sysl/once/pkgmancheck.lua"] = "sysl/runcheck.lua"
  files.other["/sysl/services/pkgman_s.lua"] = "sysl/pkgman_s.lua"
  deps.sysl = true
end

-- It makes sense to support running a function before and after packages have been updated.
local function preInstall() end
local function postInstall() end

return {
  files = files,
  deps = deps,
  preInstall = preInstall,
  postInstall = postInstall,
}