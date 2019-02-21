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
function Util.set_to_string(table, dont_print_key)
  local result = "{"
  local add_comma = false

  for k,v in pairs(table) do
    if add_comma then
      result = result .. ", "
    else
      add_comma = true
    end

    if (dont_print_key) then
      result = result
    else
      result = result .. tostring(k) .. ":"
    end
    if (Util.isTable(v) and v.token) then
      result = result .. tostring(v.token.cargo)
    else
      result = result .. tostring(v)
    end
  end
  -- result = result .. "}"
  return result .. "}"
end

function Util.set_to_string_dumb(table)
  local result = "{"
  local add_comma = false

  for k,v in pairs(table) do
    if add_comma then
      result = result .. ", "
    else
      add_comma = true
    end

    result = result .. tostring(k) .. ":" .. tostring(v)
  end
  return result .. "}"
end

function Util.set_to_string_nested_nodes(table, dont_print_key)
  local result = "{"
  local add_comma = false

  for k,v in pairs(table) do
    if add_comma then
      result = result .. ", "
    else
      add_comma = true
    end

    -- v is a node
    result =  result .. tostring(v.value)
  end
  return result .. "}"
end

function Util.isNumber(val)
  return type(val) == "number"
end

function Util.isTable(val)
  return type(val) == "table"
end
