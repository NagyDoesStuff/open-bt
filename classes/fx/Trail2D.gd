extends Line2D
class_name Trail2D

@export var point_freq: float = 0.01
@export var max_point_count: int = 50
@export var instability: float = 0.0

@onready var user: Node2D = get_parent()

func _ready() -> void:
	show_behind_parent = true
	
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.wait_time = point_freq
	timer.timeout.connect(place_point)
	add_child(timer)
	
	await get_tree().process_frame
	
	reparent(get_tree().root)
	
	z_index = user.z_index - 1

func _process(_delta: float) -> void:
	# Lock position and rotation.
	global_position = Vector2.ZERO
	global_rotation = 0.0

func place_point() -> void:
	if user: 
		var pt: Vector2 = user.global_position + Vector2.UP * randf_range(-instability*.5, instability*.5)
		add_point(to_local(pt))
	else: 
		remove_point(0)
	while get_point_count() > max_point_count:
		remove_point(0)
	if points.is_empty(): queue_free()
