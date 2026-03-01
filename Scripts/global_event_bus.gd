extends Node

signal pause

signal unpause

signal next_level

signal restart_level

signal build_mode_changed(enabled,bool)

signal selected_block(block_type: DataTypes.Blocks)

signal loot_collected(added_loot: Array)

signal block_successfully_selected(block_type: DataTypes.Blocks)
