extends Node2D
class_name Buildable

enum State { INACTIVE, PLACING, ACTIVE } #placed down after dragged, being dragged, unpaused

@export var block_type: DataTypes.Blocks = DataTypes.Blocks.None
var build_mode_enabled = false

@export var body_path: NodePath = ^"RigidBody2D" 

@export var bounce_force: float = 600.0
@export var push_force: float = 300.0
@export var push_direction: Vector2 = Vector2.RIGHT

var state: State = State.PLACING
var _bodies_in_wind: Array[Node2D] = []

@onready var body: Node = get_node_or_null(body_path)

func _ready():
	GlobalEventBus.block_successfully_selected.connect(_on_block_selected)
	process_mode = Node.PROCESS_MODE_ALWAYS # allow dragging while paused
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)

	# Connect signals based on object type
	match block_type:
		DataTypes.Blocks.Mushroom:
			var bounce_area = get_node_or_null("BounceArea")
			if bounce_area:
				print("meowmoew")
				bounce_area.body_entered.connect(_on_bounce_body_entered)
		DataTypes.Blocks.Bird:
			var wind_area = get_node_or_null("RigidBody2D/WindArea")
			if wind_area:
				wind_area.body_entered.connect(_on_wind_body_entered)
				wind_area.body_exited.connect(_on_wind_body_exited)

	_set_state(State.PLACING)

func _process(_delta): 
	if state == State.PLACING: 
		global_position = get_global_mouse_position().snapped(Vector2(16, 16))

func _on_build_mode_changed(enabled: bool):
	if enabled:
		build_mode_enabled = true
		_set_state(State.INACTIVE)
	elif (not enabled): #might add check later for state inactive too
		build_mode_enabled = false
		_set_state(State.ACTIVE)

func _on_block_selected(block: DataTypes.Blocks):
	if block_type==block:
		if build_mode_enabled and state == State.INACTIVE:
			_set_state(State.PLACING)

func _unhandled_input(event):
	if state == State.ACTIVE:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if global_position.distance_to(get_global_mouse_position()) < 10: #arbritrary dist
				if state == State.PLACING:
					state = State.INACTIVE
					return
				#state is inactive but not placing 
				state = State.PLACING

func _physics_process(delta):
	if state != State.ACTIVE:
		return
	if block_type == DataTypes.Blocks.Bird:
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
			
