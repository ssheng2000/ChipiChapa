extends Button

var build_mode := false
var pauses_remaining := 0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)
	pressed.connect(_on_pressed)
	_refresh_text()
	print("button init")

func set_pauses_remaining(v: int):
	pauses_remaining = v
	print("button", v)
	_refresh_text()

func _on_build_mode_changed(enabled: bool):
	build_mode = enabled
	print("build mode occurs")
	_refresh_text()

func _on_pressed():
	print("clicked")
	if build_mode:
		GlobalEventBus.unpause.emit()
	else:
		# main checks uses left 
		GlobalEventBus.pause.emit()

func _refresh_text():
	if build_mode:
		text = "Resume"
		disabled = false
	else:
		text = "Build (%d)" % pauses_remaining
		print(text)
		disabled = (pauses_remaining <= 0)
