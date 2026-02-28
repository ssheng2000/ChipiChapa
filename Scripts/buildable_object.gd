extends Node2D
class_name Buildable

enum State { INACTIVE, PLACING, ACTIVE }

@export var body_path: NodePath = ^"RigidBody2D" 
@export var number_of_obj: int = 0
@export var type: String = "block" # block, mushroom, bird

var state: State = State.INACTIVE
var dragging := false

@onready var body: Node = get_node_or_null(body_path)

func _ready():
	add_to_group("buildable")
	process_mode = Node.PROCESS_MODE_ALWAYS # allow dragging while paused

	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)

	_set_state(State.INACTIVE)

func _on_build_mode_changed(enabled: bool):
	if enabled:
		_set_state(State.PLACING)
	elif (not enabled) and state == State.PLACING: #might add check later for state inactive too
		_set_state(State.ACTIVE)

func on_left_sidebar(): #sidebar calls this
	if state == State.INACTIVE:
		_set_state(State.PLACING)

func _unhandled_input(event):
	if state != State.PLACING:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if global_position.distance_to(get_global_mouse_position()) < 32: #arbritrary dist
				dragging = true
		else:
			dragging = false

func _process(_delta):
	if state == State.PLACING and dragging:
		global_position = get_global_mouse_position().snapped(Vector2(16, 16))

func _set_state(s: State):
	state = s
	dragging = false

	match state:
		State.INACTIVE:
			_disable_physics_and_collisions()
		State.PLACING:
			_disable_physics_and_collisions()
		State.ACTIVE:
			_enable_physics_and_collisions()

func _disable_physics_and_collisions():
	if body is RigidBody2D:
		body.freeze = true
	# disable all child collshape2Ds
	_set_colliders_disabled(true)

func _enable_physics_and_collisions():
	_set_colliders_disabled(false)
	if body is RigidBody2D:
		body.freeze = false
		body.sleeping = false

# beeper

func _set_colliders_disabled(disabled: bool):
	if body == null: return
	for n in body.get_children():
		if n is CollisionShape2D:
			n.disabled = disabled

#func _on_body_entered(body):
	#if body == player:
		#blah
	#return
