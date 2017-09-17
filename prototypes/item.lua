local flangChip = {}

flangChip.name = "flang-chip"
flangChip.type = "item"
flangChip.icon = "__Flang__/graphics/flangchip.png"
flangChip.flags = { "goes-to-quickbar" }
flangChip.subgroup = "circuit-network"
flangChip.place_result="flang-chip"
flangChip.order = "c[combinators]-a[arithmetic-combinator]"
flangChip.stack_size= 50

local recipe = table.deepcopy(data.raw.recipe["arithmetic-combinator"])
recipe.enabled = true
recipe.ingredients = {{"copper-plate",200},{"steel-plate",50}}
recipe.result = "flang-chip"

-- local recipe = {}
-- recipe.type = "recipe"
-- recipe.name = "flang-chip"
-- recipe.enabled = true
-- recipe.ingredients =
-- {
--   {"copper-cable", 5},
--   {"electronic-circuit", 5},
-- }
-- recipe.result = "flang-chip"

data:extend{flangChip, recipe}


--------------------------------------
-- local fireArmor = table.deepcopy(data.raw.armor["heavy-armor"])
--
-- fireArmor.name = "flang-chip"
-- fireArmor.icons= {
--    {
--       icon=fireArmor.icon,
--       tint={r=1,g=0,b=0,a=0.3}
--    },
-- }
--
-- local recipe = table.deepcopy(data.raw.recipe["heavy-armor"])
-- recipe.enabled = true
-- recipe.ingredients = {{"copper-plate",200},{"steel-plate",50}}
-- recipe.result = "flang-chip"
--
-- data:extend{fireArmor,recipe}
