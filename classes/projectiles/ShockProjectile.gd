extends Projectile
class_name ShockProjectile

@export var shock_range: float = 200.0
@export var shock_cooldown: float = 1.0:
	set(value):
		shock_cooldown = clampf(value, min_shock_cooldown, 999999999.0)
@export var min_shock_cooldown: float = 0.1
@export var multishock_interval: float = 0.05
@export var hitscan_line: PackedScene

@export var can_boost_peers: bool = false
@export var peer_cooldown_remove: float = 0.9

var shock_timer: Timer = Timer.new()
var shock_area: Area2D = Area2D.new()

func _subready() -> void:
	shock_area.set_collision_layer_value(1, false)
	shock_area.set_collision_mask_value(1, false)
	shock_area.set_collision_layer_value(2, true)
	shock_area.set_collision_mask_value(2, true)
	add_child(shock_area)
	
	var shock_col: CollisionShape2D = CollisionShape2D.new()
	shock_col.shape = CircleShape2D.new()
	shock_col.shape.radius = shock_range
	shock_area.add_child(shock_col)
	
	shock_timer.one_shot = true
	shock_timer.timeout.connect(on_shock)
	add_child(shock_timer)
	on_shock()

func on_shock() -> void:
	var in_range_clusters: Array[Cluster] = []
	for c in shock_area.get_overlapping_areas():
		if c is Cluster:
			in_range_clusters.append(c)
	
	var in_range_projectiles: Array[Projectile] = []
	for p in shock_area.get_overlapping_areas():
		if p.get_parent() is ShockProjectile:
			in_range_projectiles.append(p.get_parent())
			
	shock_clusters(in_range_clusters)
	if can_boost_peers: boost_neighbors(in_range_projectiles)
	shock_timer.start(shock_cooldown)

func boost_neighbors(targets: Array[Projectile]) -> void:
	for c in targets:
		if is_instance_valid(c) and c != self and c is ShockProjectile and c.team == team:
			var hitline: HitscanLine = hitscan_line.instantiate()
			hitline.target_position = c.global_position
			add_child(hitline)
			c.shock_cooldown *= peer_cooldown_remove
		await get_tree().create_timer(multishock_interval).timeout

func shock_clusters(targets: Array[Cluster]) -> void:
	var hit_one_target: bool = false
	for c in targets:
		if is_instance_valid(c) and c.team != team:
			var hitline: HitscanLine = hitscan_line.instantiate()
			hitline.target_position = c.global_position
			add_child(hitline)
			
			await get_tree().process_frame
			
			if c: c.recieve_hit(prj_info["dmg_info"])
			hit_one_target = true
		await get_tree().create_timer(multishock_interval).timeout
	if !muted and hit_one_target: 
		GlobalClass.play_sound(hit_sfx)
