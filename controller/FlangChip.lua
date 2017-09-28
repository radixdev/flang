FlangChip = {}
FlangChip.__index = FlangChip

function FlangChip:new(o)
  if not o then
    error("nil constructor!")
  end

  o = {
    entity = o.entity,
    source = o.source or ""
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

function FlangChip:__tostring()
  print("source:\n" .. self.source)
end
