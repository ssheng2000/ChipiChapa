extends AudioStreamPlayer2D

@export var transition_duration := 1.0

var _tween: Tween

func fade_out():
	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "volume_db", -80.0, transition_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.finished.connect(_on_fade_out_finished)

func _on_fade_out_finished():
	stop()
