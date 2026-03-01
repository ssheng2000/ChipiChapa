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
	# Start in a sane state even if parallax isn't bound yet
	_apply_zoom(1.0)

	# Optional: let Main call play_intro() instead
	if auto_play_intro:
		play_intro()

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

	# Re-apply current zoom so the newly bound level instantly matches
	_apply_zoom(current_zoom)

func play_intro() -> void:
	playing_intro = true
	_apply_zoom(1.0)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(_apply_zoom, 1.0, 0.5, 2.0)
	tween.tween_interval(0.5)
	tween.tween_method(_apply_zoom, 0.5, 1.0, 2.0)

	tween.finished.connect(func():
		playing_intro = false
		intro_finished.emit()
	)

func _apply_zoom(z: float) -> void:
	current_zoom = z
	zoom = Vector2(z, z)

	var screen_h := get_viewport_rect().size.y

	# As we zoom out, world-space height increases.
	# Store an offset that will be applied while following the player.
	cam_offset_y = - (screen_h / z - screen_h) / 2.0

	# If we don't have parallax bound yet, we're done (camera zoom still works).
	if not sky or not clouds or not mountains or not trees or not town:
		return

	var sky_comp       = lerp(1.0 / z, 1.0, SKY_INFLUENCE)
	var clouds_comp    = lerp(1.0 / z, 1.0, CLOUDS_INFLUENCE)
	var mountains_comp = lerp(1.0 / z, 1.0, MOUNTAINS_INFLUENCE)
	var trees_comp     = lerp(1.0 / z, 1.0, TREES_INFLUENCE)
	var town_comp      = lerp(1.0 / z, 1.0, TOWN_INFLUENCE)

	# Scale the first child (assumes Sprite2D/Node2D as child 0)
	sky.get_child(0).scale       = Vector2.ONE * sky_comp
	clouds.get_child(0).scale    = Vector2.ONE * clouds_comp
	mountains.get_child(0).scale = Vector2.ONE * mountains_comp
	trees.get_child(0).scale     = Vector2.ONE * trees_comp
	town.get_child(0).scale      = Vector2.ONE * town_comp

	# Keep bottoms aligned to screen bottom while zooming (plus our camera offset)
	sky.get_child(0).position.y       = screen_h - sky_comp * z * screen_h + cam_offset_y
	clouds.get_child(0).position.y    = screen_h - clouds_comp * z * screen_h + cam_offset_y
	mountains.get_child(0).position.y = screen_h - mountains_comp * z * screen_h + cam_offset_y
	trees.get_child(0).position.y     = screen_h - trees_comp * z * screen_h + cam_offset_y
	town.get_child(0).position.y      = screen_h - town_comp * z * screen_h + cam_offset_y

	# Update repeat size to match scaled sprite width so tiling stays seamless
	var base_w := 256.0
	sky.repeat_size.x       = base_w * sky_comp
	clouds.repeat_size.x    = base_w * clouds_comp
	mountains.repeat_size.x = base_w * mountains_comp
	trees.repeat_size.x     = base_w * trees_comp
	town.repeat_size.x      = base_w * town_comp

func play_linear_intro(start_global: Vector2, end_global: Vector2, duration := 2.0) -> void:
	playing_intro = true
	global_position = start_global

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# Go start → end
	tween.tween_property(self, "global_position", end_global, duration)

	# Then end → start
	tween.tween_property(self, "global_position", start_global, duration)

	tween.finished.connect(func():
		playing_intro = false
		intro_finished.emit()
	)

func play_intro_pan_and_zoom(start_global: Vector2, end_global: Vector2) -> void:
	playing_intro = true
	global_position = start_global
	_apply_zoom(1.0)

	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# --- Track A: camera pan (sequential) ---
	tween.tween_property(self, "global_position", end_global, 2.0)
	tween.tween_interval(0.5)
	tween.tween_property(self, "global_position", start_global, 2.0)

	# --- Track B: zoom (parallel to the whole sequence above) ---
	var z := tween.parallel()
	z.tween_method(_apply_zoom, 1.0, 0.5, 2.0)
	z.tween_interval(0.5)
	z.tween_method(_apply_zoom, 0.5, 1.0, 2.0)

	tween.finished.connect(func():
		playing_intro = false
		intro_finished.emit()
	)

func _process(_delta: float) -> void:
	if not player:
		return
		
	if playing_intro:
		return
		
	# Follow player in global space + apply our computed intro offset.
	# If you only want X follow, swap the x line as shown below.
	global_position = player.global_position + follow_offset + Vector2(0.0, cam_offset_y)

	# X-only follow variant:
	# global_position.x = player.global_position.x
	# global_position.y = player.global_position.y + cam_offset_y
