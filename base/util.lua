--[[
Wraps a string or object tostring inside single quotes
]]
function dq(s)
  return "{'" .. tostring(s) .. "'}"
end
