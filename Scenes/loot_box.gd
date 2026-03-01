extends Node2D

@export var added_ice := 0
@export var added_mushrooms:= 0
@export var added_birds := 0

@onready var player = self.find_parent("Main").find_child("Player")
@onready var added_loot: Array = [added_ice, added_mushrooms, added_birds]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		GlobalEventBus.loot_collected.emit(added_loot)
		added_loot = [0,0,0]
	
