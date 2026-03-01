extends Camera2D

@export var player: Node2D

@export var sky: Parallax2D
@export var clouds: Parallax2D
@export var mountains: Parallax2D
@export var trees: Parallax2D
@export var town: Parallax2D

const SKY_INFLUENCE       = 0.0
const CLOUDS_INFLUENCE    = 0.2
const MOUNTAINS_INFLUENCE = 0.4
const TREES_INFLUENCE     = 0.7
const TOWN_INFLUENCE      = 1.0

const SKY_BASE       = Vector2(0.0, 0.0)
const CLOUDS_BASE    = Vector2(0.1, 0.1)
const MOUNTAINS_BASE = Vector2(0.2, 0.2)
const TREES_BASE     = Vector2(0.5, 0.5)
const TOWN_BASE      = Vector2(0.8, 0.8)

var current_zoom: float = 1.0

func _ready() -> void:
	_apply_zoom(1.0)
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(_apply_zoom, 1.0, 0.5, 2.0)
	tween.tween_interval(0.5)
	tween.tween_method(_apply_zoom, 0.5, 1.0, 2.0)

func _apply_zoom(z: float) -> void:
	current_zoom = z
	zoom = Vector2(z, z)
	
	var screen_h = get_viewport_rect().size.y
	
	# as we zoom out, world-space height increases, shift camera up to keep ground fixed
	var cam_offset = - (screen_h / z - screen_h) / 2.0
	position.y = cam_offset
	
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
	
	sky.get_child(0).position.y       = screen_h - sky_comp * z * screen_h + cam_offset
	clouds.get_child(0).position.y    = screen_h - clouds_comp * z * screen_h + cam_offset
	mountains.get_child(0).position.y = screen_h - mountains_comp * z * screen_h + cam_offset
	trees.get_child(0).position.y     = screen_h - trees_comp * z * screen_h + cam_offset
	town.get_child(0).position.y      = screen_h - town_comp * z * screen_h + cam_offset
	
	# update repeat size to match the scaled sprite width so tiling stays seamless
	var base_w = 256.0
	sky.repeat_size.x       = base_w * sky_comp
	clouds.repeat_size.x    = base_w * clouds_comp
	mountains.repeat_size.x = base_w * mountains_comp
	trees.repeat_size.x     = base_w * trees_comp
	town.repeat_size.x      = base_w * town_comp


func _process(delta: float) -> void:
	if player:
		position.x = player.position.x
		position.y = player.position.y
