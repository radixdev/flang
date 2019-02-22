--[[

  Implements scope for the Interpreter.

  We're creating a tree of scopes to facilitate variable lookup and scope
  backtracking.

]]

Scope = {}
Flang.Scope = Scope
Scope.__index = Scope

function Scope:new(o)
  if not o then
    error("nil constructor!")
  end

  -- Each "ptr" points to another Scope object
  -- The root scope, GLOBAL, has no pointers. Any attempt to resolve further up its
  -- lookup chain should logically fail since GLOBAL scope is where the buck stops.
  o = {
    -- The next scope up the lookup chain within the same block.
    parent_scope_ptr = o.parent_scope_ptr or nil,

    -- The scope to resume after an invocation has returned. Functions start new scope blocks by definition!
    -- This is read when determining what scope to use after a block is finished.
    call_ptr = o.call_ptr or nil,

    -- The parent scope of our block. For example, if we reach the end of our lookup chain for a
    -- method, then we'd need to continue the lookup at the global scope.
    -- The parent_scope_ptr should be nil when this gets followed.
    block_start_ptr = o.block_start_ptr or nil,

    -- The whole point of scoping ... the variables!
    variable_table = {}
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function Scope:error(msg)
  error(msg)
end

function Scope:debugPrint(msg)
  -- if (Flang.DEBUG_LOGGING) then
  --   print(msg .. " -> " .. Util.set_to_string_dumb(self) .. " tbl " .. Util.set_to_string_dumb(self.variable_table))
  -- end
end

-- A block has been entered. Our scope gets 1 level deeper.
function Scope:enterBlock()
  self:debugPrint("enterBlock")
  local nextParent = self

  -- Determine our block start ptr
  local nextBlockStart
  if (self.block_start_ptr == nil) then
    -- This must be the global scope. Block lookup will continue here
    nextBlockStart = self
  else
    -- It's already defined. Just continue the chain
    nextBlockStart = self.block_start_ptr
  end

  -- And now for our call ptr
  local nextCallPtr
  if (self.call_ptr == nil) then
    -- There isn't a call block to return to. Just nil and move on
    nextCallPtr = nil
  else
    -- There's a call somewhere behind us. Continue pointing to it
    nextCallPtr = self.call_ptr
  end

  return Scope:new({
    parent_scope_ptr = nextParent,
    block_start_ptr = nextBlockStart,
    call_ptr = nextCallPtr
  })
end

-- A block has been exited. Our scope goes up 1 level.
function Scope:exitBlock()
  self:debugPrint("exitBlock")
  -- Since the scope tree is static, we just have to return a previously linked node

  if (self.parent_scope_ptr ~= nil) then
    -- We're just normally exiting our block's scope and returning to our parent.
    return self.parent_scope_ptr
  end

  if (self.call_ptr ~= nil) then
    -- Return wasn't called, but no matter, our block's execution has ended.
    return self.call_ptr
  end

  self:error("ExitBlock called but no parent scope is available.")
end

function Scope:enterCall()
  self:debugPrint("enterCall")

  -- There's no parent here. Lookup from here should continue from the block_start_ptr instead.
  local nextParent = nil
  local nextBlockStart = self.block_start_ptr

  -- Since we've just entered a call block, the call_ptr should point to the Scope we just left
  local nextCallPtr = self

  return Scope:new({
    parent_scope_ptr = nextParent,
    block_start_ptr = nextBlockStart,
    call_ptr = nextCallPtr
  })
end

function Scope:exitCall()
  self:debugPrint("exitCall")

  -- The block has ended via explicit return. The call ptr should be followed
  -- to determine which scope to return
  if (self.call_ptr ~= nil) then
    return self.call_ptr
  end

  self:error("exitCall called but no call_ptr was available")
end

-- Returns the scope that contains the variable with "name"
function Scope:getContainerScopeForVariable(name)
  -- print("Variable lookup on " .. name .. " on " .. Util.set_to_string_dumb(self) .. " with table " .. Util.set_to_string_dumb(self.variable_table))
  -- Check ourselves!
  if (self.variable_table[name] ~= nil) then
    return self
  end

  -- Check our parent
  if (self.parent_scope_ptr ~= nil) then
    return self.parent_scope_ptr:getContainerScopeForVariable(name)
  end

  -- Check the block start
  if (self.block_start_ptr ~= nil) then
    return self.block_start_ptr:getContainerScopeForVariable(name)
  end

  return nil
end

function Scope:getVariable(name, throw_undefined_error)
  if (throw_undefined_error == nil) then
    throw_undefined_error = true
  end
  local containerScope = self:getContainerScopeForVariable(name)

  if (containerScope == nil) then
    -- No scope exists for our variable
    if (throw_undefined_error) then
      self:error("Variable lookup failed for name <" .. name .. ">. Undefined.")
    else
      return nil
    end
  end

  return containerScope.variable_table[name]
end

function Scope:setVariable(name, value)
  self:debugPrint("Calling set for " .. name)
  local containerScope = self:getContainerScopeForVariable(name)

  if (containerScope == nil) then
    -- No scope exists for our variable. Thus WE are the proper scope!
    containerScope = self
    self:debugPrint("    no scope found for " .. name .. " on set. WE ARE SCOPE!")
  end

  containerScope.variable_table[name] = value
end
