require("lang.base.flang_import")

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

    is_running = o.is_running or false,

    -- debug shit
    -- optional straight to player console function
    printer = o.printer
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function FlangChip:update_source(source)
  self:stop_execution()
  self.source = source
end

--[[
  Start the program, recreate the Flang interpreter.
  Does not call interpret however, simply readies the interpreter for it
]]
function FlangChip:start_execution()
  -- recreate everything
  local success, result = pcall(create_flang_interpreter,self.source)
  if success then
    self.interpreter = result
    self.is_running = true
    self.printer("interpreter execution successful", true)
  else
    self.printer("interpreter error", true)
    self:on_error(result)
    self.is_running = false
  end

  return result
end

--[[
  Stops the program.
  Does not modify the interpreter
]]
function FlangChip:stop_execution()
  if (self.is_running) then
    self.printer("execution stopped")
  end
  self.is_running = false
end

function FlangChip:execute()
  if not self.is_running then return end

  if not self.interpreter then
    -- create the interpreter
    self:start_execution()

    -- if the interpreter failed here, then just return
    -- this check is duplicated so we don't keep trying to create the interpreter
    -- and error loop into oblivion
    if not self.is_running then return end
  end

  local success, result = pcall(self.interpreter.interpret, self.interpreter)
  if success then
    -- result is our symbol table
    for k,v in pairs(self.interpreter.symbol_table_global) do
      self.printer("key " .. k)
      self.printer("val " .. v)
    end
  else
    self.is_running = false
    self.printer("execution error")
    self:on_error(result)
  end
end

function FlangChip:on_error(error)
  -- fuck
  self.printer("got error!")
  self.printer(tostring(error))
end

function create_flang_interpreter(source)
  local lexer = Flang.Lexer:new({sourceText = source})
  local parser = Flang.Parser:new({lexer = lexer})
  local interpreter = Flang.Interpreter:new({parser = parser})
  return interpreter
end

function FlangChip:__tostring()
  print("source:\n" .. self.source)
end

-- Flang.DEBUG_LOGGING = true

-- -- Routes all print statements to the player chat.
-- -- SHOULD NOT BE PRESENT IN PRODUCTION!
-- local oldprint = print
-- print = function(...)
--   player_info_window_print(..., false)
-- end
