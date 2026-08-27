extends Line2D
class_name HitscanLine

var origin: Node2D
var target_position: Vector2

@export var fade_time: float = 0.1
@export var point_count: int = 6
@export var instability: float = 30.0

func _ready() -> void:
	origin = get_parent()
	scale = Vector2.ONE
	z_index -= 1
	
	await get_tree().process_frame
	reparent(get_tree().root)
	create_tween().tween_property(self, "modulate:a", 0.0, fade_time).finished.connect(queue_free)

func _process(_delta: float) -> void:
	# Lock position and rotation.
	global_position = Vector2.ZERO
	global_rotation = 0.0
	if origin:
		points = []
		for x in range(point_count):
			var increment: Vector2 = target_position - origin.global_position
			var calc: Vector2 = to_local(origin.global_position + x * (increment/point_count))
			add_point(calc + Vector2.UP.rotated(increment.angle()) * randf_range(-instability*.5, instability*.5))
