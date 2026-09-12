extends Camera2D
class_name DynamicCamera

var max_offset: Vector2 = Vector2(20, 10)
var max_roll: float = 0.4

var shake: float = 0.0
var shake_power: float = 1.0
var shake_decay: float = 0.3

var mouse_offset_mult: float = 0.1
var mouse_offset_lerp_speed: float = 6.0
var target_zoom: Vector2 = Vector2.ONE

var anchor: Node2D:
	set(value):
		anchor = value
		if anchor is Cluster:
			target_zoom = Vector2.ONE - Vector2.ONE * ((anchor.cluster_class - 1) * 0.075)

var static_cam: bool = false

func _ready() -> void:
	position_smoothing_speed = 20.0
	position_smoothing_enabled = true
	ignore_rotation = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(_delta: float) -> void:
	shake = max(shake - shake_decay * _delta, 0)
	global_rotation = max_roll * pow(shake, shake_power) * randf_range(-1, 1)
	
	var shake_offset: Vector2 = Vector2(
		(max_offset.x * pow(shake, shake_power) * randf_range(-1, 1)),
		(max_offset.y * pow(shake, shake_power) * randf_range(-1, 1))
	)
	var mouse_offset: Vector2 = lerp(offset, get_local_mouse_position() * mouse_offset_mult, _delta * mouse_offset_lerp_speed) 
	offset = shake_offset + mouse_offset
	
	if static_cam:
		zoom = lerp(zoom, target_zoom * 0.5, _delta * 3)
		global_position = GlobalClass.current_arena.global_position
	elif anchor: 
		global_position = anchor.global_position
		zoom = lerp(zoom, target_zoom, _delta * 3)
	
	if Input.is_action_just_pressed("toggle_cam"):
		static_cam = !static_cam

func add_shake(value: float) -> void:
	shake += value
