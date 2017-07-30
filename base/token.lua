if not Flang then Flang = {} end
Token = {}
Flang.Token = Token
Token.__index = Token

--[[
Takes a character as input
]]
function Token:new(startCharacter)
  if not startCharacter then
    error("nil constructor!")
  end

  -- The cargo is a character object. The position info is encoded inside it already!
  o = {
    cargo = startCharacter.cargo,
    lineIndex = startCharacter.lineIndex,
    columnIndex = startCharacter.columnIndex,

    -- The token type is known after consuming characters, thus is starts as nil
    type = nil
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

function Token:__tostring()
  cargo = self.cargo
  if cargo == " " then cargo = "\tSPACE" end
  if cargo == "\n" then cargo = "\tNEWLINE" end
  if cargo == "\t" then cargo = "\tTAB" end
  if cargo == Character.ENDMARK then cargo = "\tEOF" end

  return
   "line: '" .. self.lineIndex .. "'"
  .. "\t column: '" .. self.columnIndex .. "'"
  .. "\t type '" .. self.type .. "'"
  .. "\t'" .. cargo .. "'"
end
