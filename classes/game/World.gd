extends Node2D
class_name World

signal entered_arena()

var mid_battle: bool = false

var arenas_travelled: int = 0
var max_class: int = 1
var max_gp: int = 0
var player_progression_requirement: int = GlobalClass.PROGRESSION_REQUIREMENTS[0]
var last_player_position: Vector2

@onready var start_arena: Arena = $Arena

@onready var ui: GameUI = $UI

var dynamic_cam: DynamicCamera = DynamicCamera.new()

func _ready() -> void:
	GlobalClass.world = self
	GlobalClass.current_arena = start_arena
	
	ui.editor.debug = false
	
	generate_arena()
	
	add_child(dynamic_cam)
	
	var flash: ScreenFlash = GlobalClass.SCREEN_FLASH.instantiate()
	flash.color = Color(1.0, 1.0, 1.0, 0.784)
	flash.flash_duration = 2.0
	ui.add_child(flash)
	flash.flash()
	
	await get_tree().process_frame
	
	dynamic_cam.anchor = GlobalClass.player_cluster
	
	if GlobalClass.free_mode:
		GlobalClass.player_cluster.max_progress = GlobalClass.PROGRESSION_REQUIREMENTS[GlobalClass.MAX_CLASS - 1]
		player_progression_requirement = GlobalClass.PROGRESSION_REQUIREMENTS[GlobalClass.MAX_CLASS - 1]
		max_class = GlobalClass.MAX_CLASS
		max_gp = int(INF)
		GlobalClass.player_cluster.progress = GlobalClass.player_cluster.max_progress
		
func generate_arena() -> void:
	pass

func get_projectiles() -> Array[Projectile]:
	var list: Array[Projectile] = []
	
	for c in get_children():
		if c is Projectile:
			list.append(c)
	
	return list

func get_clusters() -> Array[Cluster]:
	var list: Array[Cluster] = []
	
	for c in get_children():
		if c is Cluster:
			list.append(c)
	
	return list

func transform_player_into(cluster: Cluster) -> void:
	if GlobalClass.player_cluster: 
		last_player_position = GlobalClass.player_cluster.global_position
		GlobalClass.player_cluster.queue_free()
	GlobalClass.player_cluster = cluster
	for p in cluster.get_parts():
		p.disabled = false
		p.editor_mode = false
	call_deferred("add_child", GlobalClass.player_cluster)
	await get_tree().process_frame
	GlobalClass.player_cluster.global_position = last_player_position
	GlobalClass.player_cluster.max_progress = player_progression_requirement
	GlobalClass.player_cluster.enabled = true
	dynamic_cam.anchor = GlobalClass.player_cluster
	GlobalClass.player_cluster.team = 0
	
	if GlobalClass.free_mode:
		GlobalClass.player_cluster.progress = GlobalClass.player_cluster.max_progress

func spawn_as_enemy(cluster: Cluster) -> void:
	cluster.team = 1
	cluster.global_position = GlobalClass.player_cluster.global_position
	for p in cluster.get_parts():
		p.disabled = false
		p.editor_mode = false
	add_child(cluster)

func check_battle_state() -> void:
	await get_tree().create_timer(0.1).timeout
	for c in get_clusters():
		if c.team != 0:
			mid_battle = true
			return
	mid_battle = false
	for p in get_projectiles():
		p.destroy()

func transfer_player_to_next_arena(angle: float = 0.0) -> void:
	arenas_travelled += 1
	GlobalClass.player_cluster.velocity = Vector2.ZERO
	
	for c in get_clusters():
		if c != GlobalClass.player_cluster:
			c.queue_free()
	
	var new_arena: Arena = GlobalClass.ARENA_TEMPLATE.instantiate()
	new_arena.global_position = GlobalClass.current_arena.global_position + Vector2.RIGHT.rotated(angle) * GlobalClass.ESTIMATED_ARENA_RADIUS + Vector2.RIGHT.rotated(angle) * GlobalClass.DISTANCE_BETWEEN_ARENAS
	new_arena.scale = GlobalClass.DEFAULT_ARENA_SCALE
	add_child(new_arena)
	
	GlobalClass.player_cluster.enabled = false
	await create_tween().tween_property(
		GlobalClass.player_cluster, 
		"global_position", 
		new_arena.global_position + Vector2.LEFT.rotated(angle) * GlobalClass.ESTIMATED_ARENA_RADIUS * GlobalClass.DEFAULT_ARENA_SCALE * GlobalClass.LAND_ON_ARENA_DIST, 
		1).set_trans(Tween.TRANS_CIRC).finished
	
	GlobalClass.current_arena.queue_free()
	GlobalClass.current_arena = new_arena
	
	await get_tree().create_timer(0.1).timeout
	
	GlobalClass.player_cluster.enabled = true
	if new_arena: new_arena.spawn_clusters()
	
	entered_arena.emit()
	
func upgrade_player() -> void:
	if max_class == GlobalClass.MAX_CLASS: return
	
	max_class += 1
	max_gp += GlobalClass.get_gp_increment(max_class)
	if len(GlobalClass.PROGRESSION_REQUIREMENTS) >= max_class:
		player_progression_requirement = GlobalClass.PROGRESSION_REQUIREMENTS[max_class - 1]
		GlobalClass.player_cluster.max_progress = GlobalClass.PROGRESSION_REQUIREMENTS[max_class - 1]
	GlobalClass.player_cluster.progress = 1
	ui.editor_confirm_dialog.activate()
