extends Node2D
class_name Buildable

enum State { INACTIVE, PLACING, ACTIVE }


@export var body_path: NodePath = ^"RigidBody2D" 
@export var number_of_obj: int = 0
@export var type: String = "block" # block, mushroom, bird

@export var object_type: String = "block"
@export var bounce_force: float = 600.0
@export var push_force: float = 300.0
@export var push_direction: Vector2 = Vector2.RIGHT

var state: State = State.ACTIVE
var dragging := false
var _bodies_in_wind: Array[Node2D] = []

@onready var body: Node = get_node_or_null(body_path)

func _ready():
	add_to_group("buildable")
	process_mode = Node.PROCESS_MODE_ALWAYS # allow dragging while paused

	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)

	# Connect signals based on object type
	match object_type:
		"mushroom":
			var bounce_area = get_node_or_null("BounceArea")
			if bounce_area:
				print("meowmoew")
				bounce_area.body_entered.connect(_on_bounce_body_entered)
		"bird":
			
			var wind_area = get_node_or_null("RigidBody2D/WindArea")
			if wind_area:
				wind_area.body_entered.connect(_on_wind_body_entered)
				wind_area.body_exited.connect(_on_wind_body_exited)

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

func _physics_process(delta):
	_set_state(State.ACTIVE)
	if state != State.ACTIVE:
		return
	if object_type == "bird":
		for b in _bodies_in_wind:
			if b is CharacterBody2D:
				b.position += push_direction.normalized() * push_force * delta

# ── Mushroom ──
func _on_bounce_body_entered(b: Node2D):
	#if state != State.ACTIVE:
		#return
	if b is CharacterBody2D:  # could also use b.is_in_group() to filter between players and other obj
		b.velocity.y = -bounce_force

# ── Bird / Fan ── and b.is_in_group("player")
func _on_wind_body_entered(b: Node2D):
	if b is CharacterBody2D:
		_bodies_in_wind.append(b)

func _on_wind_body_exited(b: Node2D):
	_bodies_in_wind.erase(b)

# ── State management ──
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
	
