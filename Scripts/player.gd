extends CharacterBody2D

@onready var sprite = $Sprite2D

var SPEED = 100.0
const JUMP_VELOCITY = -400.0

## Step climbing settings
const MAX_STEP_HEIGHT := 20.0  # Max ledge height (pixels) the player can walk up

## The character always moves. Arrow keys flip the direction.
var move_dir := 1.0  # 1.0 = right, -1.0 = left

func _ready() -> void:
	# This starts the "run" animation immediately when the game starts
	sprite.play("run")
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Change direction on key press (not held – just the tap).
	#if Input.is_action_just_pressed("ui_right"):
		#move_dir = 1.0
	#elif Input.is_action_just_pressed("ui_left"):
		#move_dir = -1.0

	# Always move in the current direction.
	velocity.x = move_dir * SPEED

	move_and_slide()

	# --- Step / ledge climbing ---
	# If we hit a wall we can't step up, reverse direction.
	if is_on_floor():
		if not _try_step_up(move_dir):
			move_dir *= -1.0
			
	if move_dir > 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true


## Automatically walk up small steps using test_move().
## Returns true if the step was climbed (or there was no obstacle).
## Returns false if there's a wall that can't be stepped over.
##
## Algorithm (all checks use the player's real collision shape):
##   1. test_move forward – if nothing blocks us, there's no step. Bail out.
##   2. test_move upward by MAX_STEP_HEIGHT – if blocked, ceiling is too low.
##   3. From that raised position, test_move forward again.
##      If still blocked, the wall is taller than MAX_STEP_HEIGHT. Bail out.
##   4. From the raised+forward position, test_move downward to find the
##      step surface. The remainder tells us the exact step height.
##   5. Snap the player up by that height.
func _try_step_up(dir: float) -> bool:
	var forward := Vector2(dir, 0.0).normalized()
	var move_dist := absf(velocity.x) * get_physics_process_delta_time()
	if move_dist < 0.5:
		move_dist = 0.5  # minimum probe distance so we still detect a step when starting from rest

	var horizontal := forward * move_dist

	# 1. Are we actually blocked horizontally?
	#    If we can move forward freely there is no step to climb.
	if not test_move(global_transform, horizontal):
		return true  # No obstacle – all good.

	# 2. Can we move upward by MAX_STEP_HEIGHT?
	var up := Vector2(0, -MAX_STEP_HEIGHT)
	var up_collision := KinematicCollision2D.new()
	var up_blocked := test_move(global_transform, up, up_collision)
	# How far we actually moved up (may be less if ceiling is close).
	var actual_up := up if not up_blocked else up + up_collision.get_remainder()

	# 3. From the raised position, try to move forward.
	var raised_xform := global_transform
	raised_xform.origin += actual_up
	if test_move(raised_xform, horizontal):
		return false  # Still blocked – wall is taller than MAX_STEP_HEIGHT.

	# 4. From raised + forward, cast downward to find the step surface.
	var forward_xform := raised_xform
	forward_xform.origin += horizontal
	var down := Vector2(0, MAX_STEP_HEIGHT)  # probe back down
	var down_collision := KinematicCollision2D.new()
	var down_blocked := test_move(forward_xform, down, down_collision)

	if not down_blocked:
		return false  # No ground found ahead – it's a gap, don't step into the void.

	# The travel tells us how far down we went before hitting the surface.
	var down_travel := down - down_collision.get_remainder()
	# Step height = how much higher the step surface is than our current feet.
	var step_height: float = -actual_up.y - down_travel.y
	if step_height <= 0.0 or step_height > MAX_STEP_HEIGHT:
		return false

	# Snap the player up onto the step.
	global_position.y -= step_height
	return true
