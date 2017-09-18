local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "flang-chip"
entity.minable = {hardness = 0.2, mining_time = 0.5, result = "flang-chip"}
entity.max_health = 271
entity.icon = "__Flang__/graphics/flangchip.png"

data:extend{entity}
