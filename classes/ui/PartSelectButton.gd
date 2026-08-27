extends Button
class_name PartSelectButton

var editor: Editor

var part: Part:
	set(value):
		part = value
		apply_part()

func _ready() -> void:
	if editor: editor.changed_info.connect(monitor_editor)
	await get_tree().process_frame
	monitor_editor()

func monitor_editor() -> void:
	if part_gp_is_valid() and part_min_class_is_valid() and part_max_class_is_valid():
		disabled = false
	else:
		disabled = true

func apply_part() -> void:
	text = part.name
	$MarginContainer/GP.text = str(part.gp_usage)

func part_gp_is_valid() -> bool:
	return editor.available_gp >= part.gp_usage

func part_min_class_is_valid() -> bool:
	return editor.edited_cluster.cluster_class >= part.min_class

func part_max_class_is_valid() -> bool:
	return editor.edited_cluster.cluster_class <= part.max_class
