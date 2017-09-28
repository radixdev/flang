FlangChip = {}
FlangChip.__index = FlangChip

function FlangChip:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    entity = o.entity,
    source = o.source or "",
    interpreter = nil,

    is_running = false,

    -- debug shit
    -- optional straight to player console function
    printer = o.printer or nil
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function FlangChip:update_source(source)
  self.source = source
end

--[[
  Start the program, recreate the Flang interpreter.
  Does not call interpret however, simply readies the interpreter for it
]]
function FlangChip:start_execution()
  -- recreate everything
  local success, result = pcall(create_flang_interpreter(source))
  if success then
    self.interpreter = result
    self.is_running = true
  else
    self:on_error(result)
  end
end

--[[
  Stop the program.
  Does not modify the interpreter
]]
function FlangChip:stop_execution()
  self.is_running = false
end

function FlangChip:execute()
  if not self.is_running then return end

  local sucess, result = pcall(self.interpreter:interpret())
  if success then
    -- result is our symbol table
  else
    self:on_error(result)
  end
end

function FlangChip:on_error(error)
  -- fuck

  -- Call a callback?
end

function FlangChip:__tostring()
  print("source:\n" .. self.source)
end

function create_flang_interpreter(source)
  local lexer = Flang.Lexer:new({sourceText = source})
  local parser = Flang.Parser:new({lexer = lexer})
  local interpreter = Flang.Interpreter:new({parser = parser})
  return interpreter
end
