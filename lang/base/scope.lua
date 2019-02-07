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
  o = {
    -- The next scope up the lookup chain within the same block.
    parent_scope_ptr = o.parent_scope_ptr,

    -- The scope to resume after an invocation has returned. Functions start new scope blocks by definition!
    -- This is read when determining what scope to use after a block is finished.
    call_ptr = o.call_ptr,

    -- The parent scope of our block. For example, if we reach the end of our lookup chain for a
    -- method, then we'd need to continue the lookup at the global scope.
    -- The parent_scope_ptr should be nil when this gets followed.
    block_start_ptr = o.block_start_ptr,

    -- The whole point of scoping ... the variables!
    variable_table = {}
  }

  setmetatable(o, self)
  self.__index = self

  return o
end
