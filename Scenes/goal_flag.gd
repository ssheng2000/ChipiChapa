extends Node2D

@onready var sprite = $Area2D/AnimatedSprite2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self.find_parent("Main").find_child("Player"):
		GlobalEventBus.next_level.emit()
		return

func _ready():
	sprite.play("default")
