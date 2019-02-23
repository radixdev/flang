local flangChip = {}

flangChip.name = "flang-chip"
flangChip.type = "item"
flangChip.icon = "__Flang__/graphics/flangchip.png"
flangChip.flags = { "goes-to-quickbar" }
flangChip.subgroup = "circuit-network"
flangChip.place_result = "flang-chip"
flangChip.stack_size = 50
flangChip.icon_size = 32

local invis_chip_item = {
  type = "item",
  name = "invis-flang-chip",
  icon = "__Flang__/graphics/flangchip.png",
  flags = { "hidden" },
  subgroup = "circuit-network",
  place_result = "invis-flang-chip",
  order = "b[combinators]-c[invis-flang-chip]",
  stack_size = 1,
  icon_size = 32
}

data:extend({flangChip, invis_chip_item})
