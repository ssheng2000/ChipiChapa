extends Node2D

@export var added_ice := 0
@export var added_mushrooms:= 0
@export var added_birds := 0

@onready var player = self.find_parent("Main").find_child("Player")
@onready var added_loot: Array = [added_ice, added_mushrooms, added_birds]

@onready var chest_closed = preload("res://Assets/Sprites/Chest/chest_closed.png")
@onready var chest_open = preload("res://Assets/Sprites/Chest/chest_opened.png")

@onready var sprite = $Area2D/Sprite2D

@onready var open_sfx = $OpenSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = chest_closed
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		GlobalEventBus.loot_collected.emit(added_loot)
		open_sfx.play()
		sprite.texture = chest_open
		added_loot = [0,0,0]
	


func _on_open_sfx_finished() -> void:
	open_sfx.stop()
