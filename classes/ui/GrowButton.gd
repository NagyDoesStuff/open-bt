extends TextureButton
class_name GrowButton

@export var grow_add: float = 0.1
@export var final_color: Color = Color.WHITE * 2
@export var time_to_grow: float = 0.1

var init_scale: Vector2
var init_color: Color

var crr_tween: Tween

func _ready() -> void:
	init_scale = scale
	init_color = modulate
	mouse_entered.connect(
		func () -> void:
			crr_tween = create_tween().set_parallel()
			crr_tween.tween_property(
				self, 
				"scale", 
				scale + scale * grow_add, 
				time_to_grow
			).set_trans(Tween.TRANS_CUBIC)
			crr_tween.tween_property(
				self, 
				"modulate", 
				final_color, 
				time_to_grow
			)
	)
	mouse_exited.connect(
		func () -> void:
			crr_tween.kill()
			scale = init_scale
			modulate = init_color
	)
