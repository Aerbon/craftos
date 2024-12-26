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

if args[1] == "launch" then
  launch()
end