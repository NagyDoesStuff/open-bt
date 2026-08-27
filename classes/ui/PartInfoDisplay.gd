extends Control
class_name PartInfoDisplay

@onready var name_text: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Name
@onready var gp_text: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/GP
@onready var class_text: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Class
@onready var summary_text: Label = $MarginContainer/VBoxContainer/Summary
@onready var flavor_text: Label = $MarginContainer/VBoxContainer/Flavor
@onready var display: Panel = $MarginContainer/VBoxContainer/HBoxContainer/Display

func update_text(part: Part) -> void:
	name_text.text = "Name: " + str(part.name)
	gp_text.text = "GP: " + str(part.gp_usage)
	class_text.text = "Class must between " + str(part.min_class) + " and " + str(part.max_class) + " to be used."
	summary_text.text = part.summary
	flavor_text.text = part.flavor_text
	
	for c in display.get_children():
		c.queue_free()
	
	var displayed_copy: Part = part.duplicate()
	displayed_copy.z_index = 0
	displayed_copy.scale *= 0.8
	displayed_copy.position = display.size / 2
	display.add_child(displayed_copy)
