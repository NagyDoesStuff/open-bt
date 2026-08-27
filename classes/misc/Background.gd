extends Node
class_name Background

@export var color_change_frequency: float = 30.0
@export var transition_rate: float = 4.0

@onready var tex_rect_texture: TextureRect = $TextureRect
@onready var tex_gradient: Gradient = tex_rect_texture.texture.gradient

var init_colors: PackedColorArray = []

func _ready() -> void:
	init_colors = tex_gradient.colors
	
	var color_change_timer: Timer = Timer.new()
	color_change_timer.timeout.connect(change_color)
	color_change_timer.wait_time = color_change_frequency
	color_change_timer.autostart = true
	add_child(color_change_timer)

func change_color() -> void:
	var mutated_colors: PackedColorArray = tex_gradient.colors.duplicate()
	var rand_shift_amount: float = randf_range(-0.03, 0.03)
	for c in range(mutated_colors.size()):
		var new_color: Color = mutated_colors[c]
		new_color.h = init_colors[c].h + rand_shift_amount
		mutated_colors.set(c, new_color)
	print("background info: ")
	print("current colors: " + str(tex_gradient.colors))
	print("mutated colors: " + str(mutated_colors))
	
	var tween: Tween = create_tween()
	for c in range(tex_gradient.colors.size()):
		tween.tween_method(
			func (color: Color) -> void:
				tex_gradient.set_color(c, color),
			tex_gradient.colors[c], 
			mutated_colors[c], 
			transition_rate
		)
