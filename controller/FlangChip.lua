require("lang.base.flang_import")

FlangChip = {}
FlangChip.__index = FlangChip

function FlangChip:new(o)
  if not o then
    error("nil constructor!")
  end

  if (not o.entity) then
    error("nil entity!")
  end

  o = {
    entity = o.entity,
    source = o.source or "",
    interpreter = nil,

    is_running = o.is_running or false,

    invis_chip = o.invis_chip,

    -- straight to editor window logging section function
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
  local success, result = pcall(create_flang_interpreter, self.source, self.entity, self.printer)
  if success then
    self.interpreter = result
    self.is_running = true
    self:print("interpreter execution successful", true)
  else
    self:print("interpreter error", true)
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
    self:print("execution stopped")
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

  self:print("", true)
  local success, result = pcall(self.interpreter.interpret, self.interpreter)
  if not success then
    self.is_running = false
    self:printGlobalVars()
    self:print("\nexecution error")
    self:on_error(result)
  end
end

function FlangChip:on_error(error)
  -- fuck
  self:print("got error!")
  self:print(tostring(error))
end

function FlangChip:printGlobalVars()
  self:print("Current vars: \n")
  -- result is our symbol table
  for k,value in pairs(self.interpreter.global_symbol_scope.variable_table) do
    if (Util.isTable(value)) then
      self:print(k .. " = " .. Util.set_to_string(value, true))
    else
      self:print(k .. " = " .. tostring(value))
    end
  end
end

function FlangChip:print(msg, shouldClear)
  if (shouldClear == nil) then
    shouldClear = false
  end
  self.printer(self.entity, msg, shouldClear)
end

function create_flang_interpreter(source, entity, printer)
  local lexer = Flang.Lexer:new({sourceText = source})
  local parser = Flang.Parser:new({lexer = lexer})

  -- Create our wrapper to pass in for function calls
  local wrapper = {
    entity = entity,
    printer = printer
  }
  local interpreter = Flang.Interpreter:new({parser = parser, wrapper = wrapper})
  return interpreter
end

function FlangChip:__tostring()
  print("source:\n" .. self.source)
end
