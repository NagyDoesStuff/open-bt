extends Control
class_name HUD

@onready var fps_label: Label = $MarginContainer/VBoxContainer/FPS
@onready var progression_num: Label = $MarginContainer2/Panel/MarginContainer/Points
@onready var bubblefields_travelled_label: Label = $MarginContainer/VBoxContainer/BubblefieldsTravelled
@onready var cluster_name_label: Label = $MarginContainer2/Panel/MarginContainer/Name

@onready var progression_bar: ProgressBar = $MarginContainer2/Panel/MarginContainer/ProgressBar
@onready var progression_bar_container: MarginContainer = $MarginContainer2

var mid_transition: bool = false

var show_offset: float = 150.0

func _ready() -> void:
	if !GlobalClass.world: return
	
	for x in range(2):
		await get_tree().process_frame
	
	update_progression_bar()

func _process(_delta: float) -> void:
	if !GlobalClass.world: return
	
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())
	bubblefields_travelled_label.text = "Bubblefields travelled: " + str(GlobalClass.world.arenas_travelled)

func update_progression_bar() -> void:
	progression_bar.value = int(GlobalClass.player_cluster.progress)
	progression_bar.max_value = GlobalClass.player_cluster.max_progress
	progression_num.text = str(int(GlobalClass.player_cluster.max_progress - GlobalClass.player_cluster.progress)) + " Bubbles left"
	cluster_name_label.text = GlobalClass.player_cluster.name
	
	if !mid_transition:
		mid_transition = true
		var target_y: float = progression_bar_container.global_position.y - show_offset
		await create_tween().tween_property(progression_bar_container, "global_position:y", target_y, 0.5).set_trans(Tween.TRANS_CUBIC).finished
	
		await get_tree().create_timer(3.0).timeout
	
		target_y = progression_bar_container.global_position.y + show_offset
		await create_tween().tween_property(progression_bar_container, "global_position:y", target_y, 0.5).set_trans(Tween.TRANS_CUBIC).finished
		mid_transition = false
