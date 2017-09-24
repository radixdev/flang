local flangChip = {}

flangChip.name = "flang-chip"
flangChip.type = "item"
flangChip.icon = "__Flang__/graphics/flangchip.png"
flangChip.flags = { "goes-to-quickbar" }
flangChip.subgroup = "circuit-network"
flangChip.place_result="flang-chip"
flangChip.stack_size= 50

data:extend{flangChip}
