--[[
A Scanner object reads through the sourceText
and returns one character at a time.
--]]
Scanner = {}
Flang.Scanner = Scanner
Scanner.__index = Scanner


--[[
*args*
(string) sourceText - the entire text
--]]
function Scanner:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    sourceText = o.sourceText,
    lastIndex = string.len(o.sourceText) - 1,
    sourceIndex = 0,
    -- Lines should start at 1
    lineIndex = 1,
    columnIndex = -1
  }

  setmetatable(o, self)
  self.__index = self
  return o
end

--[[
*return*
(string) - Returns the next character in sourceText.
--]]
function Scanner:get()
  -- increment the source index
  self.sourceIndex = self.sourceIndex + 1

  -- maintain the line count
  if (self.sourceIndex > 0) then
    if (self:getChar(self.sourceIndex - 1) == "\n") then
      -- The previous character was a newline.
      --  reset the column and increment the line index
      self.lineIndex = self.lineIndex + 1
      self.columnIndex = 0
    end
  end

  -- scan the line
  self.columnIndex = self.columnIndex + 1

  if (self.sourceIndex > self.lastIndex) then
    -- We've read past the end sourceText
    -- return ENDMARK
    character = Flang.Character:new({cargo = Flang.Character.ENDMARK,
      sourceIndex = self.sourceIndex, lineIndex = self.lineIndex,
      columnIndex = self.columnIndex
    })
  else
    charAtIndex = self:getChar(self.sourceIndex)
    character = Flang.Character:new({cargo = charAtIndex,
      sourceIndex = self.sourceIndex, lineIndex = self.lineIndex,
      columnIndex = self.columnIndex
    })
  end

  return character
end

function Scanner:getChar(index)
  return string.sub(self.sourceText, index, index)
end

--[[
Returns the string (not character) at some offset from the current index
]]
function Scanner:lookahead(offset)
  -- get the offet
  index = self.sourceIndex + offset

  if (index > self.lastIndex) then
    -- read past the end of the text, EOF
    return Flang.Character.ENDMARK
  else
    return self:getChar(index)
  end
end
