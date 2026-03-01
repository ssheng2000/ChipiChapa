extends Camera2D

signal intro_finished

@export var player: Node2D

@export var auto_play_intro := false

@export var follow_offset := Vector2(0, -50)


# These get assigned by bind_parallax() when a level loads
var sky: Parallax2D
var clouds: Parallax2D
var mountains: Parallax2D
var trees: Parallax2D
var town: Parallax2D

const SKY_INFLUENCE       = 0.0
const CLOUDS_INFLUENCE    = 0.2
const MOUNTAINS_INFLUENCE = 0.4
const TREES_INFLUENCE     = 0.7
const TOWN_INFLUENCE      = 1.0

var current_zoom: float = 1.0
var cam_offset_y: float = 0.0
var playing_intro := false

func _ready() -> void:
	pass
	# Start in a sane state even if parallax isn't bound yet

	# Optional: let Main call play_intro() instead
	#if auto_play_intro:
		#play_intro()

func bind_parallax(
	p_sky: Parallax2D,
	p_clouds: Parallax2D,
	p_mountains: Parallax2D,
	p_trees: Parallax2D,
	p_town: Parallax2D
) -> void:
	sky = p_sky
	clouds = p_clouds
	mountains = p_mountains
	trees = p_trees
	town = p_town

func _set_position(pos: Vector2):
	position = pos
	
	var screen_h = get_viewport_rect().size.y
	
	sky.get_child(0).position.x       = pos.x * (1-SKY_INFLUENCE)
	clouds.get_child(0).position.x    = pos.x * (1-CLOUDS_INFLUENCE)
	mountains.get_child(0).position.x = pos.x * (1-MOUNTAINS_INFLUENCE)
	trees.get_child(0).position.x     = pos.x * (1-TREES_INFLUENCE)
	town.get_child(0).position.x      = pos.x * (1-TOWN_INFLUENCE)
	
	sky.get_child(0).position.y       = pos.y - screen_h / 2
	clouds.get_child(0).position.y    = pos.y - screen_h / 2
	mountains.get_child(0).position.y = pos.y - screen_h / 2
	trees.get_child(0).position.y     = pos.y - screen_h / 2
	town.get_child(0).position.y      = pos.y - screen_h / 2

func _set_zoom(z: float):
	zoom = Vector2(z, z)
	
	var screen_w = get_viewport_rect().size.x
	var screen_h = get_viewport_rect().size.y
	var cam_offset = 0
	
	var sky_comp       = lerp(1.0 / z, 1.0, SKY_INFLUENCE)
	var clouds_comp    = lerp(1.0 / z, 1.0, CLOUDS_INFLUENCE)
	var mountains_comp = lerp(1.0 / z, 1.0, MOUNTAINS_INFLUENCE)
	var trees_comp     = lerp(1.0 / z, 1.0, TREES_INFLUENCE)
	var town_comp      = lerp(1.0 / z, 1.0, TOWN_INFLUENCE)
	
	sky.get_child(0).scale       = Vector2.ONE * sky_comp
	clouds.get_child(0).scale    = Vector2.ONE * clouds_comp
	mountains.get_child(0).scale = Vector2.ONE * mountains_comp
	trees.get_child(0).scale     = Vector2.ONE * trees_comp
	town.get_child(0).scale      = Vector2.ONE * town_comp
	
	sky.get_child(0).position.y       = position.y + screen_h / 2 - sky_comp * z * screen_h + cam_offset
	clouds.get_child(0).position.y    = position.y + screen_h / 2 - clouds_comp * z * screen_h + cam_offset
	mountains.get_child(0).position.y = position.y + screen_h / 2 - mountains_comp * z * screen_h + cam_offset
	trees.get_child(0).position.y     = position.y + screen_h / 2 - trees_comp * z * screen_h + cam_offset
	town.get_child(0).position.y      = position.y + screen_h / 2 - town_comp * z * screen_h + cam_offset
	
	var base_w = 256.0
	sky.repeat_size.x       = base_w * sky_comp
	clouds.repeat_size.x    = base_w * clouds_comp
	mountains.repeat_size.x = base_w * mountains_comp
	trees.repeat_size.x     = base_w * trees_comp
	town.repeat_size.x      = base_w * town_comp
	
func play_intro_pan_and_zoom(start_global: Vector2, end_global: Vector2) -> void:
	playing_intro = true
	_set_position(start_global)
	_set_zoom(1.0)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# --- Track A: camera pan (sequential) ---
	tween.tween_method(_set_position, start_global, end_global, 2.0)
	tween.tween_interval(0.5)
	tween.tween_method(_set_position, end_global, start_global, 2.0)

	# --- Track B: zoom (parallel to the whole sequence above) ---
	var z := tween.parallel()
	z.tween_method(_set_zoom, 1.0, 0.5, 2.0)
	z.tween_interval(0.5)
	z.tween_method(_set_zoom, 0.5, 1.0, 2.0)

	tween.finished.connect(func():
		playing_intro = false
		intro_finished.emit()
	)

func _process(_delta: float) -> void:
	if not player:
		return
		
	if playing_intro:
		return
		
	_set_position(player.global_position + Vector2(0, -50))

	
