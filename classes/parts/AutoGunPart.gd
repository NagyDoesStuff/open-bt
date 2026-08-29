extends GunPart
class_name AutoGunPart

@export_enum(
	"Auto",
	"Lock-on"
) var mode: String = "Auto"
@export_enum(
	"Random",
	"Strongest Target",
	"Weakest Target"
) var targeting_mode: String = "Random"
@export var prediction_factor: float = 10.0

@export_group("Lock-on Only")
@export var lock_on_icon_speed: float = 10.0
@export var lock_on_icon_scene: PackedScene = preload("uid://cpxdyxm6xaq4p")
@export var show_lock_on: bool = false
@export var lock_on_animation_hold_time: float = 1.0
@export var lock_on_animation_name: String = "new_target"

var lock_on_icon: Node2D = lock_on_icon_scene.instantiate()

var target: Cluster

func _subready() -> void:
	barrels = get_barrels()
	
	if !disabled and !editor_mode:
		search_for_target()
		if GlobalClass.world:
			GlobalClass.world.entered_arena.connect(search_for_target)
		if show_lock_on: 
			GlobalClass.world.add_child(lock_on_icon)

func search_for_target() -> void:
	# Slight delay so the target isnt the same as the one killed.
	await get_tree().process_frame
	 
	var enemies: Array[Cluster] = []
	
	for c in GlobalClass.world.get_clusters():
		if c.team != user.team:
			enemies.append(c)
	
	if enemies.is_empty(): return
	
	target = enemies.pick_random()
	target.killed.connect(search_for_target)
	
	if lock_on_icon and !lock_on_icon.get_node("AnimationPlayer").is_playing():
		lock_on_icon.get_node("AnimationPlayer").play(lock_on_animation_name)
		await get_tree().create_timer(lock_on_animation_hold_time).timeout
		lock_on_icon.get_node("AnimationPlayer").play("hide_bar")

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled or !user.can_fire: return
	
	lock_on_icon.visible = is_instance_valid(target)
	if is_instance_valid(target):
		turn_to(target.global_position + target.velocity * prediction_factor, _delta)
		match mode:
			"Auto": 
				if can_shoot: fire_all_barrels()
			"Lock-on" when user == GlobalClass.player_cluster:
				if can_shoot and Input.is_action_pressed(keybind): fire_all_barrels()
				lock_on_icon.global_position = lerp(
					lock_on_icon.global_position,
					target.global_position,
					_delta * lock_on_icon_speed
				)
	else: 
		turn_to(global_position + Vector2.RIGHT.rotated(user.global_rotation), _delta)
		lock_on_icon.global_position = global_position
