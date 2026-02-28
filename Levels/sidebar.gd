extends Area2D

func _ready():
	body_exited.connect(_on_body_exited)

func _on_body_exited(body):
	if body.is_in_group("buildable"):
		print("rahhh body build")
		body.on_left_sidebar()
