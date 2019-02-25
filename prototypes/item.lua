local flangChip = {}

flangChip.name = "flang-chip"
flangChip.type = "item"
flangChip.icon = "__Flang__/graphics/flangchip.png"
flangChip.flags = { "goes-to-quickbar" }
flangChip.subgroup = "circuit-network"
flangChip.place_result = "flang-chip"
flangChip.stack_size = 50
flangChip.icon_size = 32

local invisChip = {}
invisChip.name = "invis-flang-chip"
invisChip.type = "item"
invisChip.icon = "__Flang__/graphics/flangchip.png"
invisChip.flags = { "hidden" }
invisChip.subgroup = "circuit-network"
invisChip.place_result = "invis-flang-chip"
invisChip.order = "b[combinators]-c[invis-flang-chip]"
invisChip.stack_size = 1
invisChip.icon_size = 32

data:extend({flangChip, invisChip})
