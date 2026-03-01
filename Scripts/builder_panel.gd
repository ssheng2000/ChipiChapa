extends Control

@onready var ice_button:= $MarginContainer/HBoxContainer/IceButton
@onready var mushroom_button:= $MarginContainer/HBoxContainer/MushroomButton
@onready var bird_button:= $MarginContainer/HBoxContainer/BirdButton

var selected_block: DataTypes.Blocks = DataTypes.Blocks.None

func _ready():
	GlobalEventBus.set_top_controls_visibility.connect(_on_control_visibility)
	visible = false

func _on_control_visibility(v: bool):
	visible = v

func select_block(block_type: DataTypes.Blocks) -> void:
	if GlobalEventBus.lock != null:
		GlobalEventBus.lock.queue_free()
		
	GlobalEventBus.selected_block.emit(block_type)
	selected_block = block_type
	
func _on_ice_button_pressed() -> void:
	print("ice")
	select_block(DataTypes.Blocks.Ice)


func _on_mushroom_button_pressed() -> void:
	print("mushroom")
	select_block(DataTypes.Blocks.Mushroom)


func _on_bird_button_pressed() -> void:
	print("bird")
	select_block(DataTypes.Blocks.Bird)
