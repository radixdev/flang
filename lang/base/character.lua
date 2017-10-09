Character = {}
Flang.Character = Character
Character.__index = Character

--[[
A Character object holds
    - one character (self.cargo)
    - the index of the character's position in the sourceText.
    - the index of the line where the character was found in the sourceText.
    - the index of the column in the line where the character was found in the sourceText.
    !- (a reference to) the entire sourceText (self.sourceText)

This information will be available to a token that uses this character.
If an error occurs, the token can use this information to report the
line/column number where the error occurred, and to show an image of the
line in sourceText where the error occurred.
--]]

Character.ENDMARK = "\0"

--[[
(string) cargo - the character
--]]
function Character:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    cargo = o.cargo,
    sourceIndex = o.sourceIndex,
    lineIndex = o.lineIndex,
    columnIndex = o.columnIndex
  }

  if (string.len(o.cargo) ~= 1) then
    error("character must be 1 char long. got: '" .. o.cargo .. "'")
  end

  setmetatable(o, self)
  self.__index = self
  return o
end

function Character:__tostring()
  cargo = self.cargo
  if cargo == " " then cargo = "\tSPACE" end
  if cargo == "\n" then cargo = "\tNEWLINE" end
  if cargo == "\t" then cargo = "\tTAB" end
  if cargo == Character.ENDMARK then cargo = "\tEOF" end

  return
   "line: '" .. self.lineIndex .. "'"
  .. "\t column: '" .. self.columnIndex .. "'"
  .. "\t sourceIndex: '" .. self.sourceIndex .. "'"
  .. "\t'" .. cargo .. "'"
end
