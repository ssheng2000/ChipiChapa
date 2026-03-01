extends BuildableBlocks
class_name BuildableBird

@export var push_force: float = 300.0
@export var is_blowing_right: bool = true

@onready var sprite := $RigidBody2D/AnimatedSprite2D
@onready var wind_area := $RigidBody2D/WindArea
@onready var wind_particles:= $RigidBody2D/WindArea/GPUParticles2D


var _drag_start_x := 0.0

var push_direction: Vector2
var _bodies_in_wind: Array[Node2D] = []

var _wind_gravity_mag := 0.0

func _ready() -> void:
	super._ready()

	push_direction = Vector2.RIGHT if is_blowing_right else Vector2.LEFT

	if wind_area:
		wind_area.rotation = push_direction.angle()
		wind_area.body_entered.connect(_on_wind_body_entered)
		wind_area.body_exited.connect(_on_wind_body_exited)
	
	var mat := wind_particles.process_material as ParticleProcessMaterial
	_wind_gravity_mag = absf(mat.gravity.x)
	
	_set_facing(is_blowing_right)

func _on_active_physics_process(delta: float) -> void:
	for b in _bodies_in_wind:
		if b is CharacterBody2D:
			b.position += push_direction.normalized() * push_force * delta

func _on_wind_body_entered(b: Node2D) -> void:
	if b is CharacterBody2D:
		_bodies_in_wind.append(b)

func _on_wind_body_exited(b: Node2D) -> void:
	_bodies_in_wind.erase(b)


# override to allow flipping
func _process(delta: float) -> void:
	super._process(delta)

	if state == State.PLACING:
		var dx := get_global_mouse_position().x - _drag_start_x
		
		if absf(dx) > 2.0: # small deadzone so it doesn't flicker
			_set_facing(dx > 0.0)
	
	if state == State.PLACING:
		_drag_start_x = get_global_mouse_position().x

func _set_facing(face_right: bool) -> void:
	# Mirror visuals
	var flip_scale = 1.0 if face_right else -1.0
	sprite.scale.x = flip_scale
	print(flip_scale)
	
	#wind area and particles
	wind_area.scale.x = 1.0 if face_right else -1.0
	var mat := wind_particles.process_material as ParticleProcessMaterial
	mat.gravity.x = _wind_gravity_mag if face_right else -_wind_gravity_mag
	wind_particles.restart()  # so it updates immediately

	# Update push direction used in wind push
	push_direction = Vector2.RIGHT if face_right else Vector2.LEFT
