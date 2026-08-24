extends Control
class_name EditorConfirmDialog

@onready var ignore_button: Button = $MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/Ignore
@onready var go_to_editor_button: Button = $MarginContainer/VBoxContainer/Options/MarginContainer/HBoxContainer/GoToEditor

@onready var choices_container: HBoxContainer = $MarginContainer/VBoxContainer/Choices/MarginContainer/ScrollContainer/HBoxContainer

func _ready() -> void:
	configure_signals()
	hide()

func activate() -> void:
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.0)
	show()
	
	GlobalClass.player_cluster.enabled = false
	
	pick_and_make_choices()

func configure_signals() -> void:
	go_to_editor_button.pressed.connect(go_to_editor)
	ignore_button.pressed.connect(quit)

func pick_choice(cluster: Cluster) -> void:
	GlobalClass.world.transform_player_into(cluster)
	GlobalClass.player_cluster_filename = GlobalClass.get_load_location(cluster)
	quit()

func quit() -> void:
	hide()
	GlobalClass.player_cluster.enabled = true

func go_to_editor() -> void:
	hide()
	GlobalClass.can_pause = false
	GlobalClass.world.ui.toggle_editor(true)
	GlobalClass.world.ui.hud.hide()
	GlobalClass.world.ui.editor.load_cluster(GlobalClass.player_cluster_filename)

func pick_and_make_choices() -> void:
	for c in choices_container.get_children():
		c.queue_free()
	
	var available_choices: Array[Cluster] = []
	for c in GlobalClass.loaded_clusters:
		var c_gp: int = c.get_used_gp()
		var min_gp: int = GlobalClass.world.max_gp - GlobalClass.get_gp_increment(GlobalClass.world.max_class)
		if c.team == 0 and c.available_as_choice and c.cluster_class <= GlobalClass.world.max_class and c_gp <= GlobalClass.world.max_gp and c_gp > min_gp:
			available_choices.append(c)
	available_choices.shuffle()
	if available_choices.is_empty(): return
	
	var already_chosen_names: Array[String] = []
	for x in GlobalClass.UPGRADE_CHOICES:
		var picked: Cluster = available_choices.pick_random()
		
		if already_chosen_names.has(picked.name): continue
		else: already_chosen_names.append(picked.name)
		
		var dupe: Cluster = picked.duplicate()
		dupe.enabled = false
		
		var button: Button = GlobalClass.TANK_CHOICE_BUTTON.instantiate()
		button.get_node("Panel/Label").text = dupe.name
		
		var loaded_path: String = GlobalClass.get_load_location(dupe)
		button.pressed.connect(pick_choice.bind(load(loaded_path).instantiate()))
		choices_container.add_child(button)
		
		await get_tree().process_frame
		
		dupe.position = button.size / 2
		dupe.scale = Vector2.ONE * 0.75
		button.add_child(dupe)
