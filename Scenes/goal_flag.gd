extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self.find_parent("Main").find_child("Player"):
		GlobalEventBus.next_level.emit()
		return
