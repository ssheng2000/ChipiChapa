extends Node

# defines signal for build mode, init build mode as false 

signal build_mode_changed(enabled: bool)

var build_mode := false

func enter_build_mode():
	if build_mode: return
	build_mode = true
	get_tree().paused = true
	emit_signal("build_mode_changed", true)

func exit_build_mode():
	if not build_mode: return
	build_mode = false
	get_tree().paused = false
	emit_signal("build_mode_changed", false)
