-- This prefix points to my package repository
local masterurl = "https://raw.githubusercontent.com/Aerbon/craftos/master/"

print("Reading package list.")
local packagelist = fs.open(".aepkgs/list.txt","r")
if packagelist == nil then
  print("Package list not found.")
else
  local pkgname = fs.readLine()
  while pkgname ~= nil do
    local url = masterurl .. pkgname .. "/updater.lua"
    shell.run("wget run " .. url)
  end
  print("No more packages listed.")
  packagelist.close()
