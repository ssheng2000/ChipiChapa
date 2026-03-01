extends Node2D

@export var instance_parent : Node2D
@export var scene_ice : PackedScene
@export var scene_mushroom : PackedScene = preload("res://Scenes/mushroom.tscn")
@export var scene_bird : PackedScene = preload("res://Scenes/bird.tscn")

@export var pauses_amount := 3
@export var ice_amount := 0
@export var mushroom_amount := 0
@export var bird_amount := 0

# Parallax things exposed
@onready var sky: Parallax2D = $Parallax/Sky
@onready var clouds: Parallax2D = $Parallax/Clouds
@onready var mountains: Parallax2D = $Parallax/Mountains
@onready var trees: Parallax2D = $Parallax/Trees
@onready var town: Parallax2D = $Parallax/Town

@onready var pause_button := $Build_UI/MarginContainer/PauseButton

@onready var mushroom_label := self.find_child("MushroomLabel")
@onready var ice_label := self.find_child("IceLabel")
@onready var bird_label := self.find_child("BirdLabel")
@onready var pause_label := self.find_child("PauseLabel")

enum Mode { RUN, BUILD }

var mode: Mode = Mode.RUN
var pauses_remaining := pauses_amount
var block_selected: DataTypes.Blocks = DataTypes.Blocks.None

func _ready():
	GlobalEventBus.pause.connect(_on_pause_requested)
	GlobalEventBus.unpause.connect(_on_unpause_requested)
	GlobalEventBus.selected_block.connect(_on_block_select)
	GlobalEventBus.loot_collected.connect(_on_loot_collected)
	_update_pause_button()
	set_level_data()

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
	print("pauses remaining", pauses_remaining)
	_update_pause_button()
	set_level_data()
	_set_mode(Mode.BUILD)

func _on_unpause_requested():
	if mode == Mode.RUN:
		return
	_set_mode(Mode.RUN)

func _update_pause_button():
		if pause_button and pause_button.has_method("set_pauses_remaining"):
				pause_button.set_pauses_remaining(pauses_remaining)

func select_block(block: DataTypes.Blocks) -> int:
	if block==DataTypes.Blocks.Ice:
		if ice_amount>0:
			ice_amount-=1
			set_level_data()
			block_selected = block
			try_create_buildable(scene_ice)
			GlobalEventBus.block_successfully_selected.emit(block)
			return ice_amount
	if block==DataTypes.Blocks.Mushroom:
		if mushroom_amount>0:
			mushroom_amount-=1
			set_level_data()
			block_selected = block
			try_create_buildable(scene_mushroom)
			GlobalEventBus.block_successfully_selected.emit(block)
			return mushroom_amount
	if block==DataTypes.Blocks.Bird:
		if bird_amount>0:
			bird_amount-=1
			set_level_data()
			block_selected = block
			try_create_buildable(scene_bird)
			GlobalEventBus.block_successfully_selected.emit(block)
			return bird_amount
	return 0
		

func _on_block_select(block: DataTypes.Blocks) -> void:
	if mode == Mode.BUILD:
		select_block(block)
		print("original_amounts", ice_amount, mushroom_amount, bird_amount)
	return


func try_create_buildable(block_source : PackedScene) -> Node2D:
	var instance: Node2D = block_source.instantiate()
	instance_parent.add_child(instance)
	var start_position = instance.get_global_mouse_position()
	instance.global_position = start_position
	return instance
	
func _on_loot_collected(added_loot):
	ice_amount += added_loot[0]
	mushroom_amount += added_loot[1]
	bird_amount += added_loot[2]
	set_level_data()
	print("updated_amounts", ice_amount, mushroom_amount, bird_amount)
	
func set_level_data():
	pause_label.text    = str(pauses_remaining)
	ice_label.text      = str(ice_amount)
	mushroom_label.text = str(mushroom_amount)
	bird_label.text     = str(bird_amount)
