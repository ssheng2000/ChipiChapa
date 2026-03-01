extends Node

enum Mode { RUN, BUILD }

@export var levels: Array[PackedScene] = []
@export var cutscenes: Array[PackedScene] = []

@onready var level_container := $Levels

@onready var easy_music = $Music/EasyMusic
@onready var medium_music = $Music/MediumMusic
@onready var hard_music = $Music/HardMusic
@onready var placed_sfx = $Music/PlaceSFX
@onready var death_sfx = $Music/DeathSFX

@onready var player := $Player
@onready var camera := $Camera2D

var level_index := 0
var current_level: Node = null
var restarting = false

var cutscene_index := 0
var current_cutscene: Node = null

var intro_playing = true



func _ready():
	GlobalEventBus.next_level.connect(_on_next_level)
	GlobalEventBus.restart_level.connect(_on_restart_level)
	GlobalEventBus.death.connect(_on_death)
	GlobalEventBus.placed_block.connect(_on_block_placed)
	#GlobalEventBus.intro_finished.connect(_on_intro_finished)
	player.hide()
	_load_cutscene(0)
	_load_level(0)

func _load_level(i: int):
	print("rah")
	get_tree().paused = true
	intro_playing = true
	if not restarting:
		if (i==0):
			easy_music.play()
		if (i==1):
			easy_music.fade_out()
			medium_music.play()
		if (i==2):
			medium_music.fade_out()
			hard_music.play()
	if current_level and is_instance_valid(current_level):
		current_level.queue_free()

	current_level = levels[i].instantiate()
	level_container.add_child(current_level)
	
	var start_pos = current_level.find_child("Player_Start_Pos")
	player.global_position = start_pos.global_position
	player.show()
	player.sprite.flip_h = false
	player.move_dir = 1
	await get_tree().process_frame
	
	GlobalEventBus.set_top_controls_visibility.emit(false)
	
	camera.player = player
	camera.bind_parallax(current_level.sky, current_level.clouds, current_level.mountains, current_level.trees, current_level.town)
	camera.intro_finished.connect(_on_camera_intro_finished, CONNECT_ONE_SHOT)
	#camera.play_linear_intro(current_level.find_child("Player_Start_Pos").global_position, current_level.find_child("Goal_Flag").global_position)
	camera.play_intro_pan_and_zoom(
		current_level.find_child("Player_Start_Pos").global_position + Vector2(0, -50),
		current_level.find_child("Goal_Flag").global_position
	)
	


func _on_next_level():
	print("naur")
	
	level_container.remove_child(current_level)
	level_index += 1
	if level_index >= len(levels):
		get_tree().paused
		return
	_load_level(level_index)

func _on_restart_level():
	restarting = true
	_load_level(level_index)
	restarting = false
	
func _load_cutscene(i: int):
	return
	
func _on_death():
	death_sfx.play()
	await death_sfx.finished
	GlobalEventBus.restart_level.emit()
	
	return
	
func _on_camera_intro_finished():
	GlobalEventBus.set_top_controls_visibility.emit(true)
	get_tree().paused = false
	intro_playing = false
	return

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		if not intro_playing:
			GlobalEventBus.restart_level.emit()
			
func _on_block_placed():
	placed_sfx.play()
	
	


func _on_death_sfx_finished() -> void:
	death_sfx.stop()
	pass # Replace with function body.


func _on_place_sfx_finished() -> void:
	placed_sfx.stop()
	pass # Replace with function body.
