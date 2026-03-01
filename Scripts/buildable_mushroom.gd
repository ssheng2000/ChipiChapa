extends BuildableBlocks
class_name BuildableMushroom

enum MushState { IDLE, CHARGED, BOUNCING }

@export var bounce_force: float = 360.0

var mush_state = MushState.IDLE

# unused
var player_in_bounce_area = false

@onready var player = self.find_parent("Main").find_child("Player")
@onready var anim_sprite: AnimatedSprite2D = $RigidBody2D/AnimatedSprite2D

func _ready() -> void:
	super._ready()
	anim_sprite.animation_finished.connect(_on_anim_finished)
	anim_sprite.play("idle")


func _on_player_collision_area_body_entered(body: Node2D) -> void:
	if state != State.ACTIVE or body != player or mush_state == MushState.BOUNCING:
		return
		
	if mush_state == MushState.IDLE:
		mush_state = MushState.CHARGED
		anim_sprite.play("press")
		print("mush CHARGED")
	elif mush_state == MushState.CHARGED:
		mush_state = MushState.BOUNCING
		anim_sprite.play("bounce")
		bounce()
		print("mush BOUNCING")
 

func _on_player_collision_area_body_exited(body: Node2D) -> void:
	if state != State.ACTIVE or body != player:
		return
	if mush_state == MushState.BOUNCING:
		mush_state = MushState.IDLE



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

func _on_anim_finished():
	if anim_sprite.animation == "bounce":
		if mush_state == MushState.CHARGED:
			anim_sprite.play("press")
		else:
			anim_sprite.play("idle")
