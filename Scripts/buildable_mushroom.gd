extends BuildableBlocks
class_name BuildableMushroom

enum MushState { IDLE, CHARGED, BOUNCING }

@export var bounce_force: float = 600.0

var mush_state = MushState.IDLE

# unused
var player_in_bounce_area = false

@onready var player = self.find_parent("Main").find_child("Player")

# unused
@onready var bouncearea = $RigidBody2D/BounceArea

func _ready() -> void:
	super._ready()
	print(player)


func _on_player_collision_area_body_entered(body: Node2D) -> void:
	if state != State.ACTIVE or body != player or mush_state == MushState.BOUNCING:
		return
		
	if mush_state == MushState.IDLE:
		mush_state = MushState.CHARGED
		print("mush CHARGED")
	elif mush_state == MushState.CHARGED:
		mush_state = MushState.BOUNCING
		bounce()
		print("mush BOUNCING")
 

func _on_player_collision_area_body_exited(body: Node2D) -> void:
	if state != State.ACTIVE or body != player:
		return
	if mush_state == MushState.BOUNCING:
		mush_state = MushState.IDLE
		print("mush reset to IDLE")



# unused
func _on_bounce_area_body_entered(body: Node2D) -> void:
	if state != State.ACTIVE or body != player:
		return
	player_in_bounce_area = true
	pass # Replace with function body.


# unused
func _on_bounce_area_body_exited(body: Node2D) -> void:
	if state != State.ACTIVE or body != player:
		return
	player_in_bounce_area = false
	pass # Replace with function body.

func bounce():
	print("boing")
	player.velocity.y = -bounce_force
