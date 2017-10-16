-- see \Factorio\data\base\prototypes\entity\entities.lua line 10459
local entity = table.deepcopy(data.raw["constant-combinator"]["constant-combinator"])
entity.name = "flang-chip"
entity.minable = {hardness = 0.2, mining_time = 0.5, result = "flang-chip"}
entity.max_health = 271
entity.icon = "__Flang__/graphics/flangchip.png"
entity.item_slot_count = 100

data:extend{entity}
