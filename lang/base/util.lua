Util = {}
Flang.Util = Util
Util.__index = Util

Flang.DEBUG_LOGGING = false
Flang.VERBOSE_LOGGING = false

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

--[[
  Creates strings like:
  {a:1, b:2, c:4}
]]
function Util.set_to_string(table)
  local result = "{"
  local add_comma = false

  for k,v in pairs(table) do
    if add_comma then
      result = result .. ", "
    else
      add_comma = true
    end

    result = result .. tostring(k) .. ":" .. tostring(v.token.cargo)
  end
  -- result = result .. "}"
  return result .. "}"
end
