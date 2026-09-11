extends Label
class_name FloatingText

var velocity: Vector2 = Vector2.ZERO
var upwards_impulse: float = 10.0
var sideways_impulse: float = 3.0
var gravity: float = 0.25

@export var fade_in_time: float = 0.1
@export var no_fade_time: float = 0.4
@export var fade_out_time: float = 0.1

func _ready() -> void:
	velocity += Vector2.UP * randf_range(0, upwards_impulse)
	velocity += Vector2.RIGHT * randf_range(-sideways_impulse, sideways_impulse)
	
	if fade_in_time > 0.0:
		modulate.a = 0.0
		await create_tween().tween_property(self, "modulate:a", 1.0, fade_in_time).finished
	
	if no_fade_time > 0.0:
		await get_tree().create_timer(no_fade_time).timeout
	
	if fade_out_time > 0.0:
		await create_tween().tween_property(self, "modulate:a", 0.0, fade_out_time).finished
		
	queue_free()


func _process(_delta: float) -> void:
	velocity += Vector2.DOWN * gravity
	global_position += velocity
