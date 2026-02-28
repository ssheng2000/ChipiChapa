extends Node2D

@export var pauses_amount := 3

enum Mode { RUN, BUILD }

@onready var pause_button := $PauseButton

var mode: Mode = Mode.RUN
var pauses_remaining := pauses_amount

func _ready():
	GlobalEventBus.pause.connect(_on_pause_requested)
	GlobalEventBus.unpause.connect(_on_unpause_requested)

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
	if pause_button and pause_button.has_method("set_uses_left"):
		pause_button.set_pauses_remaining(pauses_remaining)
