-- AKA Update V3

-- This program should not depend on other pre-existing files, for the sake of ease of installation.

local args = {...} -- Alway rember

local FileUrlPrefix = "https://raw.githubusercontent.com/Aerbon/craftos/master/"
local PathToPkgConf = "/.aepkgs/config.pkgs"
local PathToPkgList = "/.aepkgs/installed.pkgs"

local function connectionCheck()
  return 
end

local function readSer(path)
  local file = fs.open(path, "r")
  local result = {}
  if file ~= nil then
    return textutils.unserialise(file.readAll())
  else
    print("Could not unserialize \"" .. path .. "\".")
  end
end

local function writeSer(content, path)
  local file = fs.open(path, "w")
  file.write(textutils.serialise(content))
  file.close()
end

local function getUpstreamVersion(path)
  path = path or ""
  local request = {
    url = "http://api.github.com/repos/Aerbon/craftos/commits?path=" .. path,
    headers = {
      Accept = "application/vnd.github+json"
    },
    timeout = 15
  }
  local response = http.get(request)
  local result = textutils.unserialiseJSON(response.readAll())
  response.close()
  return result[1].sha
end

local function tableEq(this, that)
  if type(this) ~= type(that) then return false end
  keys = {}
  for key, value in pairs(this) do
    if type(value) == "table" and tableEq(value, that[key]) then
    elseif value ~= that[key] then
      return false
    end
    keys[key] = true
  end
  for key in pairs(that) do
    if keys[key] then else return false end
  end
  retunr true
end

local function upstreamHasChanged()
  local upstream_has_changed = false
  do
    local request = {
      url = "http://api.github.com/repos/craftos/commits",
      headers = {
        Accept = "application/vnd.github+json"
      }
    }
    local response = http.get(request)
    local result = textutils.unserialiseJSON(response.readAll())
    response.close()
    if fs.exists(".aepkgs/last_commit.txt") then
      local file = fs.open(".aepkgs/last_commit.txt", "r")
      local last_commit = file.readAll()
      file.close()
      if result[1].sha ~= last_commit then
        upstream_has_changed = true
      end
    else
      upstream_has_changed = true
    end
    if upstream_has_changed then
      local file = fs.open(".aepkgs/last_commit.txt","w")
      file.write(result[1].sha)
      file.close()
    end
  end
  return upstream_has_changed
end

local function configHasChanged(changelog)
  -- Load config if it exists
  local config = {}
  if fs.exists(PathToPkgConf) then
    config = readSer(PathToPkgConf)
  else
    return true
  end
  -- Load existing package list
  local pkgs = {}
  if fs.exists(PathToPkgList) then
    pkgs = readSer(PathToPkgList)
  else
    return true
  end
  local seen = {}
  for pkg, val in pairs(config) do
    if val.install ~= pkgs[pkg].installed or not tableEq(val.options, pkgs[pkg].options) then
      if changelog then else return true end
    end
    seen[pkg] = true
  end
  for pkg in pairs(pkgs) do
    if not seen[pkg] then return true end
  end
  return false
end

local function multiRequest()
  local requests = {...}
  local response_count = 0
  local files = {}
  print("Downloading "..tostring(#args).." files...")
  for n, request in ipairs(args) do
    files[n] = { url = request.url, }
    local response = http.request(request)
  end
  do
    local event = {os.pullEvent()}
    if event[1] == "http_success" then
      for n in ipairs(files) do
        if event[2] == files[n].url then
          files[n].content = event[3].readAll()
          response_count = response_count + 1
        end
      end
    elseif event[1] == "http_failure" then
      for n in ipairs(files) do
        if event[2] == files[n].url then
          files[n].error = true
          response_count = response_count + 1
        end
      end
    end
  until response_count == #requests
  print("Done.")
  return files
end

local function updatePkgs(force)
  -- Load config if it exists
  local config = {}
  if fs.exists(PathToPkgConf) then
    config = readSer(PathToPkgConf)
  else
    -- Otherwise create default config
    print("Creating new package config.")
    print("edit " .. PathToPkgConf .. " to declare packages.")
    config = {
      pkgmanager = {
        install = true,
      },
    }
    writeSer(config, PathToPkgConf)
  end
  -- Load existing package list
  local pkgs = {}
  if fs.exists(PathToPkgList) then
    pkgs = readSer(PathToPkgList)
  end
  local pkgchanges = {}
end

if args[1] == "update" then
  print("Checking for updates...")
  -- Install changes
  if configHasChanged() or upstream_has_changed() then
    updatePkgs(false)
    print("Done.")
  else
    print("No updates to install.")
  end
elseif args[1] == "forceupdate" then
  updatePkgs(true)
elseif args[1] == "install" then
  install(table.unpack(args,2))
else
  print("Usage: pkgman <mode> [packages]")
  print("modes: update, forceupdate, install, remove, list")
end