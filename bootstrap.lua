-- if fs.exists("startup.lua") then
--   fs.remove("startup.lua")
-- end

local pkgs = {
  sysl = { install = true, },
  pkgmanager = {
    install = true,
    options = {
      sysl = true,
      upstream = "https://raw.githubusercontent.com/Aerbon/craftos/refs/heads/indev/",
    },
  },
}

local file = fs.open("startup.lua", "w")
file.write("shell.run(\"sysl\")")
file.close()

local file = fs.open(".aepkgs/list.pkgs", "w")
file.write(textutils.serialise(pkgs))
file.close()

-- shell.setPath()

shell.run("wget run " .. pkgs.pkgmanager.upstream .. "pkgmanager/programs/pkgman.lua")