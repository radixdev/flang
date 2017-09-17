-- local entity = table.deepcopy(data.raw.entity["iron-chest"])
local entity = table.deepcopy(data.raw["container"]["iron-chest"])
entity.name = "flang-chip"

data:extend{entity}
