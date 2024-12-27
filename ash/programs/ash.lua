
function main()

  local inputBuffer = ""
  local myTerm = {
    "",
  }

  checkBuffer = function ()
    if inputBuffer:sub(1,1) ~= ":" then
      myTerm[#myTerm] = myTerm[#myTerm] .. inputBuffer
      inputBuffer = ""
    elseif inputBuffer:sub(2,2) == ":" then
      myTerm[#myTerm] = myTerm[#myTerm] .. ":"
      inputBuffer = ""
    end
  end

  local vars = {}
  local eventHandler = {}

  eventHandler["char"] = function (_, c)
    inputBuffer = inputBuffer .. c
    checkBuffer()
  end

  eventHandler["paste"] = function (_, text)
    -- TODO
  end

  eventHandler["key"] = function (_, id)
    if id == 27 then
      inputBuffer = ""
    end
  end

  while true do
    local event = {os.pullEvent()}
    local handle = eventHandler[event[1]]
    if handle ~= nil then
      handle(table.unpack(event))
    end
  end
end
