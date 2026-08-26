extends Control
class_name HUD

@onready var fps_label: Label = $MarginContainer/VBoxContainer/FPS
@onready var progression_num: Label = $MarginContainer2/Panel/MarginContainer/VBoxContainer/ProgressBar/Numbers
@onready var arenas_travelled_label: Label = $MarginContainer/VBoxContainer/ArenasTravelled

@onready var cluster_search_input: LineEdit = $MarginContainer/VBoxContainer/Panel/MarginContainer/ClusterSearch

@onready var progression_bar: ProgressBar = $MarginContainer2/Panel/MarginContainer/VBoxContainer/ProgressBar
@onready var progression_bar_container: MarginContainer = $MarginContainer2

@onready var cluster_search_input_panel: Panel = $MarginContainer/VBoxContainer/Panel

@onready var arena_button_container: HBoxContainer = $MarginContainer/VBoxContainer/HBoxContainer

@onready var increment_arenas_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button01
@onready var decrement_arenas_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/Button02


var mid_transition: bool = false

var show_offset: float = 150.0

func _ready() -> void:
	for x in range(2):
		await get_tree().process_frame
	
	update_progression_bar()
	
	configure_buttons()
	
	if GlobalClass.game_mode == "Free Mode":
		cluster_search_input_panel.show()
		arena_button_container.show()

func _process(_delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	arenas_travelled_label.text = "Arenas Travelled: " + str(GlobalClass.world.arenas_travelled)
	
	if Input.is_action_just_pressed("enter") and !cluster_search_input.text.is_empty():
		search_for_cluster(cluster_search_input.text)

func configure_buttons() -> void:
	increment_arenas_button.pressed.connect(add_arenas_travelled.bind(10))
	decrement_arenas_button.pressed.connect(add_arenas_travelled.bind(-10))

func search_for_cluster(text: String) -> void:
	var recieved_text: String = text
	var spawn_as_enemy: bool = false
	if recieved_text.ends_with(" AS_ENEMY"):
		recieved_text = recieved_text.trim_suffix(" AS_ENEMY")
		spawn_as_enemy = true
	
	var full_path: String = GlobalClass.USER_CLUSTERS_DIRECTORY + recieved_text + ".tscn"
	if FileAccess.file_exists(full_path):
		var loaded_cluster: Cluster = ResourceLoader.load(full_path).instantiate()
		if !spawn_as_enemy:
			GlobalClass.world.transform_player_into(loaded_cluster)
		else:
			GlobalClass.world.spawn_as_enemy(loaded_cluster)

func update_progression_bar() -> void:
	progression_bar.value = int(GlobalClass.player_cluster.progress)
	progression_bar.max_value = GlobalClass.player_cluster.max_progress
	progression_num.text = str(int(GlobalClass.player_cluster.progress)) + "/" + str(GlobalClass.player_cluster.max_progress)
	
	if !mid_transition:
		mid_transition = true
		var targetet_y: float = progression_bar_container.global_position.y - show_offset
		await create_tween().tween_property(progression_bar_container, "global_position:y", targetet_y, 0.5).set_trans(Tween.TRANS_CUBIC).finished
	
		await get_tree().create_timer(3.0).timeout
	
		targetet_y = progression_bar_container.global_position.y + show_offset
		await create_tween().tween_property(progression_bar_container, "global_position:y", targetet_y, 0.5).set_trans(Tween.TRANS_CUBIC).finished
		mid_transition = false

func add_arenas_travelled(value: int) -> void:
	GlobalClass.world.arenas_travelled += value
