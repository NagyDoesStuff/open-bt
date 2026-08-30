extends Area2D
class_name Cluster

# Signals

signal progress_changed()
signal killed()

# Variables

@export_group("Info")
@export var team: int = 0
@export var cluster_class: int = 1
@export var available_as_choice: bool = true
@export var attributes: Array[String] = [
	"game_cluster"
]

@export_group("Stats")
@export var speed: float = 16.0
@export var acceleration: float = 6.0
@export var turn_rate: float = 2.0
@export var drop_value: int = 10
@export var max_progress: int = 1

@export_group("Spawn Settings")
@export var min_to_available: int = 0
@export var max_spawn_amount: int = 3

var dist_from_center: float = 0.0
var damage_taken: float = 1.0

## For player tanks, this serves as the progression variable for unlocking the next class.
## For enemy tanks, this serves as the health variable.
var progress: float = 1.0:
	set(value):
		progress = clampf(value, 0, max_progress)
		progress_changed.emit()
		check_progress()

var velocity: Vector2 = Vector2.ZERO

var enabled: bool = true
var dead: bool = false
var force_ai: bool = false
var force_full_progress: bool = false
var can_fire: bool = true

# Nodes

var parts: Array[Part] = []

var controller: Controller:
	set(value):
		if !value: return
		if controller: controller.queue_free()
		controller = value
		controller.enabled = true
		add_child(controller)

var status_fx_manager: StatusEffectManager = StatusEffectManager.new()

func _ready() -> void:
	modulate.a = 0.0
	
	await get_tree().process_frame
	
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)
	
	if !enabled: return
	add_child(status_fx_manager)
	update_parts()
	
	if team == 0:
		if !force_ai: 
			controller = PlayerController.new()
			GlobalClass.player_cluster = self
			progress_changed.connect(GlobalClass.world.ui.hud.update_progression_bar)
			max_progress = GlobalClass.world.player_progression_requirement
			if cluster_class >= 4:
				speed *= 0.5
				turn_rate *= 0.25
		else:
			search_and_apply_behavior_parts()
		if force_full_progress:
			progress = max_progress
	else:
		progress = max_progress
		search_and_apply_behavior_parts()
	
	killed.connect(GlobalClass.world.check_battle_state)
	
	var check_dist_center_timer: Timer = Timer.new()
	check_dist_center_timer.autostart = true
	check_dist_center_timer.wait_time = 0.1
	check_dist_center_timer.timeout.connect(func () -> void:
		if GlobalClass.current_arena: 
			dist_from_center = global_position.distance_to(GlobalClass.current_arena.global_position)
	)
	add_child(check_dist_center_timer)
	
	set_collision_masks()

func _process(_delta: float) -> void:
	if !enabled: return
	
	global_position += velocity
	if GlobalClass.current_arena and dist_from_center > GlobalClass.ESTIMATED_ARENA_RADIUS * GlobalClass.current_arena.scale.x:
		if self == GlobalClass.player_cluster:
			GlobalClass.world.transfer_player_to_next_arena((global_position - GlobalClass.current_arena.global_position).angle())
		else:
			kill()
	
func get_parts() -> Array[Part]:
	var list: Array[Part]
	for b in get_children():
		if b is Part:
			list.append(b)
	return list

func recieve_hit(dmg_info: Dictionary, from_angle: float = 0.0) -> void:
	if !enabled: return
	match dmg_info["type"]:
		"punch":
			velocity += Vector2.RIGHT.rotated(from_angle) * dmg_info["knk"]
			progress -= dmg_info["amount"] * damage_taken
		"slowdown":
			status_fx_manager.slow_down(dmg_info["amount"], dmg_info["duration"])
		"jam":
			status_fx_manager.jam_weapons(dmg_info["duration"])
		"stun":
			status_fx_manager.stun(dmg_info["duration"])
		"steal":
			progress -= dmg_info["amount"] * damage_taken
			drop_points(dmg_info["amount"], true, true)
		"weaken":
			status_fx_manager.weaken(dmg_info["amount"], dmg_info["duration"])
		"poison":
			status_fx_manager.poison(dmg_info["amount"], dmg_info["duration"])
		_:
			progress -= dmg_info["amount"]
		
	if self == GlobalClass.player_cluster:
		GlobalClass.play_sound("uid://c2wjfumwdpyo")

func check_progress() -> void:
	if progress == max_progress and self == GlobalClass.player_cluster:
		GlobalClass.world.upgrade_player()
	
	if progress == 0:
		if self == GlobalClass.player_cluster:
			progress = 1
			await get_tree().process_frame
			GlobalClass.world.arenas_travelled = 0
			GlobalClass.world.transfer_player_to_next_arena(randf_range(0, TAU))
			GlobalClass.play_sound("uid://dayofekvd0206")
		else:
			kill()

func kill() -> void:
	if dead: return
	dead = true
	
	GlobalClass.play_sound("uid://dq4v7w25xntxg")
	killed.emit()
	drop_points(drop_value)
	if get_parent():
		get_parent().remove_child(self)
	queue_free()

func drop_points(amount: int, follow: bool = false, remove: bool = false) -> void:
	if amount <= 0: return
	if remove: 
		if amount > drop_value: return
		drop_value -= amount
	
	var avaliable_value_to_convert: int = amount
	var available_bubble_sizes: Array[int] = GlobalClass.FIXED_BUBBLE_SIZES.duplicate()
	var values_to_erase: Array[int] = []
	for size in available_bubble_sizes:
		if size > drop_value:
			values_to_erase.append(size)
	for value in values_to_erase:
		available_bubble_sizes.erase(value)
	if available_bubble_sizes.is_empty(): return
	
	while avaliable_value_to_convert > 0:
		var bubble_value: int = available_bubble_sizes.pick_random()
		
		if bubble_value > avaliable_value_to_convert:
			bubble_value = avaliable_value_to_convert
		
		var pt: BubblePoint = GlobalClass.BUBBLE_POINT.instantiate()
		pt.add_value = bubble_value
		pt.global_position = global_position
		pt.force_follow = follow
		
		avaliable_value_to_convert -= bubble_value
		GlobalClass.world.call_deferred("add_child", pt)

func get_used_gp() -> int:
	var gp: int = 0
	for p in get_parts():
		gp += p.gp_usage
	return gp

func search_and_apply_behavior_parts() -> void:
	for p in get_parts():
		if p is BehaviorPart:
			match p.type:
				"Agressive": controller = AgressorAI.new()
				"Wall Flower": controller = WallFlowerAI.new()
				"Skittish": controller = SkittishAI.new()
				"Flocking": controller = FlockingAI.new()
			return
	controller = WanderAI.new()

func set_collision_masks() -> void:
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func update_parts() -> void:
	parts = get_parts()
