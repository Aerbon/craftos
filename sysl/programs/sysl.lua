local args = {...} -- Alway rember

local function launch()
  -- run single tasks
  local tasks = {}
  for n, path in ipairs(fs.find("/sysl/once/*.lua")) do
    tasks[n] = loadfile(path)
  end
  parallel.waitForAll(table.unpack(tasks))
  -- run programs
  local services = {}
  for n, path in ipairs(fs.find("/sysl/services/*.lua")) do
    services[n] = loadfile(path)
  end
  local shouldrun = true
  while shouldrun do
    parallel.waitForAny(table.unpack(services))
  end
end

local subcommands = {}
subcommands["launch"] = function ()
  launch()
end
subcommands["help"] = function ()
  print("usage: sysl <command> [arguments]")
  print("commands: launch, help")
end

local c = subcommands[args[1]]
if c ~= nil then
  c(table.unpack(args,2))
else
  print("usage: sysl <command> [arguments]")
end