extends Node

enum Mode { RUN, BUILD }

@export var levels: Array[PackedScene] = []

@onready var level_container := $Levels

var level_index := 0
var current_level: Node = null
@onready var player := $Player

func _ready():
	GlobalEventBus.next_level.connect(_on_next_level)
	GlobalEventBus.restart_level.connect(_on_restart_level)
	player.hide()
	_load_level(0)

func _load_level(i: int):
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()

	current_level = levels[i].instantiate()
	level_container.add_child(current_level)
	
	var start_pos = current_level.find_child("Player_Start_Pos")
	player.global_position = start_pos.global_position
	player.show()
	await get_tree().process_frame


func _on_next_level():
	print("naur")
	
	level_container.remove_child(current_level)
	level_index += 1
	if level_index >= len(levels):
		get_tree().paused
		return
	_load_level(level_index)

func _on_restart_level():
	_load_level(level_index)
