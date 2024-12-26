-- if fs.exists("startup.lua") then
--   fs.remove("startup.lua")
-- end

local pkgs = {
  sysl = { install = true, },
  pkgmanager = {
    install = true,
    options = {
      sysl = true,
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

shell.run("wget run raw.githubusercontent.com/Aerbon/craftos/master/update_v2.lua")