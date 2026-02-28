extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

## Step climbing settings
const MAX_STEP_HEIGHT := 100.0  # Max ledge height (pixels) the player can walk up


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# --- Step / ledge climbing ---
	if is_on_floor() and direction != 0.0:
		_try_step_up(direction)


## Automatically walk up small steps using test_move().
##
## Algorithm (all checks use the player's real collision shape):
##   1. test_move forward – if nothing blocks us, there's no step. Bail out.
##   2. test_move upward by MAX_STEP_HEIGHT – if blocked, ceiling is too low.
##   3. From that raised position, test_move forward again.
##      If still blocked, the wall is taller than MAX_STEP_HEIGHT. Bail out.
##   4. From the raised+forward position, test_move downward to find the
##      step surface. The remainder tells us the exact step height.
##   5. Snap the player up by that height.
func _try_step_up(dir: float) -> void:
	var forward := Vector2(dir, 0.0).normalized()
	var move_dist := absf(velocity.x) * get_physics_process_delta_time()
	if move_dist < 0.5:
		move_dist = 0.5  # minimum probe distance so we still detect a step when starting from rest

	var horizontal := forward * move_dist

	# 1. Are we actually blocked horizontally?
	#    If we can move forward freely there is no step to climb.
	if not test_move(global_transform, horizontal):
		return

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
		return  # Still blocked – wall is taller than MAX_STEP_HEIGHT.

	# 4. From raised + forward, cast downward to find the step surface.
	var forward_xform := raised_xform
	forward_xform.origin += horizontal
	var down := Vector2(0, MAX_STEP_HEIGHT)  # probe back down
	var down_collision := KinematicCollision2D.new()
	var down_blocked := test_move(forward_xform, down, down_collision)

	if not down_blocked:
		return  # No ground found ahead – it's a gap, don't step into the void.

	# The travel tells us how far down we went before hitting the surface.
	var down_travel := down - down_collision.get_remainder()
	# Step height = how much higher the step surface is than our current feet.
	var step_height: float = -actual_up.y - down_travel.y
	if step_height <= 0.0 or step_height > MAX_STEP_HEIGHT:
		return

	# Snap the player up onto the step.
	global_position.y -= step_height
