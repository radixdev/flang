local flangChip = table.deepcopy(data.raw.item["arithmetic-combinator"])

flangChip.name = "flang-chip"
-- flangChip.icons= {
--    {
--       icon=flangChip.icon,
--       tint={r=1,g=0,b=0,a=0.3}
--    },
-- }

-- flangChip.resistances = {
--    {
--       type = "physical",
--       decrease = 6,
--       percent = 10
--    },
--    {
--       type = "explosion",
--       decrease = 10,
--       percent = 30
--    },
--    {
--       type = "acid",
--       decrease = 5,
--       percent = 30
--    },
--    {
--       type = "fire",
--       decrease = 0,
--       percent = 100
--    },
-- }

local recipe = table.deepcopy(data.raw.item["arithmetic-combinator"])
recipe.enabled = true
recipe.ingredients = {{"steel-plate",1}}
recipe.result = "flang-chip"

data:extend{flangChip,recipe}
