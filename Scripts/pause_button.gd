extends TextureButton

var build_mode := false
var pauses_remaining := 0

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
