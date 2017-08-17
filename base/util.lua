if not Flang then Flang = {} end
Util = {}
Flang.Util = Util
Util.__index = Util

Flang.DEBUG_LOGGING = true

--[[
Wraps a string or object tostring inside single quotes
]]
function dq(s)
  return "{'" .. tostring(s) .. "'}"
end

-- turn the Table of {element, ...} into a table of {element = true, ...}
-- will be queried later
function Util.Set(table)
  local s = {}
  for _,v in pairs(table) do s[v] = true end
  return s
end


-- Returns true if element in set, nil otherwise
function Util.contains(set, element)
  return set[element]
end
