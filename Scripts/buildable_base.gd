extends Node2D
class_name BuildableBlocks

enum State { INACTIVE, PLACING, ACTIVE }

@export var block_type: DataTypes.Blocks = DataTypes.Blocks.None
@export var body_path: NodePath = ^"RigidBody2D"

var build_mode_enabled := false
var state: State = State.PLACING

@onready var body: Node = get_node_or_null(body_path)

func _ready() -> void:
	GlobalEventBus.block_successfully_selected.connect(_on_block_selected)
	GlobalEventBus.build_mode_changed.connect(_on_build_mode_changed)

	# Allow dragging/placing while paused (you do intro pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_set_state(State.PLACING)

func _process(_delta: float) -> void:
	if state == State.PLACING:
		global_position = get_global_mouse_position().snapped(Vector2(1, 1))

func _on_build_mode_changed(enabled: bool) -> void:
	build_mode_enabled = enabled
	if enabled:
		_set_state(State.INACTIVE)
	else:
		_set_state(State.ACTIVE)

func _on_block_selected(block: DataTypes.Blocks) -> void:
	if block_type != block:
		return
	if build_mode_enabled and state == State.INACTIVE:
		_set_state(State.PLACING)

func _unhandled_input(event: InputEvent) -> void:
	if state == State.ACTIVE:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if global_position.distance_to(get_global_mouse_position()) < 10:
			# Toggle placing <-> inactive
			if state == State.PLACING:
				_set_state(State.INACTIVE)
			else:
				_set_state(State.PLACING)

# --- Hook for child classes (Bird/Mushroom/Ice) ---
func _on_active_physics_process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if state != State.ACTIVE:
		return
	_on_active_physics_process(delta)

# --- State management ---
func _set_state(s: State) -> void:
	state = s
	match state:
		State.INACTIVE, State.PLACING:
			_disable_physics_and_collisions()
		State.ACTIVE:
			_enable_physics_and_collisions()

func _disable_physics_and_collisions() -> void:
	if body is RigidBody2D:
		body.freeze = true
	_set_colliders_disabled(true)

func _enable_physics_and_collisions() -> void:
	_set_colliders_disabled(false)
	if body is RigidBody2D:
		body.freeze = false
		body.sleeping = false

func _set_colliders_disabled(disabled: bool) -> void:
	if body == null:
		return
	for n in body.get_children():
		if n is CollisionShape2D:
			n.disabled = disabled
