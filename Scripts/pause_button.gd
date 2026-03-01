extends TextureButton

var build_mode := false
var pauses_remaining := 0


@onready var play_normal = preload("res://Assets/Sprites/Icons/play.png")
@onready var play_hover = preload("res://Assets/Sprites/Icons/play_light.png")
@onready var play_pressed = preload("res://Assets/Sprites/Icons/play_dark.png")

@onready var pause_normal = preload("res://Assets/Sprites/Icons/pause.png")
@onready var pause_hover = preload("res://Assets/Sprites/Icons/pause_icon_light.png")
@onready var pause_pressed = preload("res://Assets/Sprites/Icons/pause_icon_dark.png")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)
	pressed.connect(_on_pressed)

func set_pauses_remaining(v: int):
	pauses_remaining = v

func _on_build_mode_changed(enabled: bool):
	build_mode = enabled

func _on_pressed():
	if build_mode:
		GlobalEventBus.unpause.emit()
		
	else:
		# main checks uses left 
		GlobalEventBus.pause.emit()
	update_button_visual()
	
func update_button_visual():
	if build_mode:
		texture_normal = play_normal
		texture_hover = play_hover
		texture_pressed = play_pressed
	else:
		texture_normal = pause_normal
		texture_hover = pause_hover
		texture_pressed = pause_pressed
