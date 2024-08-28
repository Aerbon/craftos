-- This prefix points to my package repository
local masterurl = "https://raw.githubusercontent.com/Aerbon/craftos/master/"
local apiurl = "http://api.github.com/repos/Aerbon/craftos/commits"

-- File locations
local pathtopkglist = ".aepkgs/list.pkgs"

-- Misc. Settings.
local http_timeout = 15


-- Functions for github REST api stuff
function getLastCommit(path)
  local request = {
    url = apiurl .. "?path=" .. path,
    headers = {
      Accept = "application/vnd.github+json"
    },
    timeout = http_timeout
  }
  local response = http.get(request)
  local result = textutils.unserialiseJSON(response.readAll())
  response.close()
  return result[1].sha
end

-- Functions for reading serialized data
function readJSON(path)
  local file = fs.open(path, "r")
  local result = {}
  if file ~= nil then
    return textutils.unserialiseJSON(file.readAll())
  else
    print("Could not unserialize \"" .. path .. "\".")
  end
end

function readSer(path)
  local file = fs.open(path, "r")
  local result = {}
  if file ~= nil then
    return textutils.unserialise(file.readAll())
  else
    print("Could not unserialize \"" .. path .. "\".")
  end
end

function writeSer(content, path)
  local file = fs.open(path, "w")
  file.write(textutils.serialise(content))
  file.close()
end

-- Check for package list files
local pkgs, oldpkgs = {}, {}
if fs.exists(pathtopkglist) then
  pkgs = readSer(pathtopkglist)
else
  print("Creating new package config.")
  print("edit " .. pathtopkglist .. " to declare packages.")
  pkgs.testpackage = {}
  pkgs.testpackage.install = true
  writeSer(pkgs, pathtopkglist)
end

if fs.exists(pathtopkglist .. ".old") then
  oldpkgs = readSer(pathtopkglist .. ".old")
end

-- Check for upstream updates
local upstream_has_changed = false
do
  local request = {
    url = apiurl,
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
    if result.node_id ~= last_commit then
      upstream_has_changed = true
      print("Upstream has changed.")
    end
  else
    upstream_has_changed = true
    print("Missing commit history.")
  end
  if upstream_has_changed then
    local file = fs.open(".aepkgs/last_commit.txt","w")
    file.write(result.node_id)
    file.close()
    print("Updates will be downloaded.")
  end
end


-- Process package changes
local to_install = {}
local to_stay = {}
local to_remove = {}

for pkg in pairs(pkgs) do
  if pkgs[pkg].install == true then
    to_install[pkg] = true
  end
end

for pkg in pairs(oldpkgs) do
  if oldpkgs[pkg].installed == true then
    if to_install[pkg] == true then
      to_install[pkg] = false
      to_stay[pkg] = true
    else
      to_remove[pkg] = true
    end
  end
end

-- Process dependencies (TODO)

local newpkgs = {} -- This will be written to oldpkgs

-- Remove old packages

-- Check and update staying packages

-- Install new packages
for pkg in pairs(to_install) do
  print("Installing " .. pkg .. "...")
  newpkgs[pkg] = {}
  shell.run("wget run " .. masterurl .. pkg .. "/update.lua")
  newpkgs[pkg].installed = true
  newpkgs[pkg].version = getLastCommit(pkg .. "/")
end

writeSer(newpkgs, pathtopkglist .. ".old")