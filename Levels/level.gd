extends Node2D

@export var pauses_amount := 3
@export var ice_amount := 0
@export var mushroom_amount := 0
@export var bird_amount := 0

enum Mode { RUN, BUILD }

@onready var pause_button := $Build_UI/MarginContainer/PauseButton

var mode: Mode = Mode.RUN
var pauses_remaining := pauses_amount
var block_selected: DataTypes.Blocks = DataTypes.Blocks.None

func _ready():
	print("LEVEL SCENE:", scene_file_path)
	GlobalEventBus.pause.connect(_on_pause_requested)
	GlobalEventBus.unpause.connect(_on_unpause_requested)
	GlobalEventBus.selected_block.connect(_on_block_select)
	print("pause button;", pause_button)
	_set_mode(Mode.RUN)
	_update_pause_button()

func _set_mode(new_mode: Mode):
		mode = new_mode
		var build_enabled := (mode == Mode.BUILD)
		get_tree().paused = build_enabled
		GlobalEventBus.build_mode_changed.emit(build_enabled)

func _on_pause_requested():
		if mode == Mode.BUILD:
				return
		if pauses_remaining <= 0:
				return

		pauses_remaining -= 1
		_update_pause_button()
		_set_mode(Mode.BUILD)

func _on_unpause_requested():
		if mode == Mode.RUN:
				return
		_set_mode(Mode.RUN)

func _update_pause_button():
		if pause_button and pause_button.has_method("set_pauses_remaining"):
				pause_button.set_pauses_remaining(pauses_remaining)

func get_block(block: DataTypes.Blocks) -> int:
	
	if block==DataTypes.Blocks.Ice:
		print("ice block", ice_amount)
		if ice_amount>0:
			ice_amount-=1
			return ice_amount
	if block==DataTypes.Blocks.Mushroom:
		print("mushroom block", mushroom_amount)
		if mushroom_amount>0:
			mushroom_amount-=1
			return mushroom_amount
	if block==DataTypes.Blocks.Bird:
		print("birdblock", bird_amount)
		if bird_amount>0:
			bird_amount-=1
			return bird_amount
	return 0
		

func _on_block_select(block: DataTypes.Blocks) -> void:
	print("block selected")
	if mode == Mode.BUILD:
		print("mode is build")
		if get_block(block) > 0:
			block_selected = block
			print("block_selected", block)
			GlobalEventBus.block_successfully_selected.emit(block)
	return
