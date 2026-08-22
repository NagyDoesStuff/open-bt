extends Projectile
class_name ShockProjectile

@export var peer_cooldown_remove: float = 0.9
@export var shock_cooldown: float = 1.0:
	set(value):
		shock_cooldown = clampf(value, min_shock_cooldown, 999999999.0)
@export var min_shock_cooldown: float = 0.1
@export var multishock_interval: float = 0.05
@export var hitscan_line: PackedScene

var shock_timer: Timer = Timer.new()

func _subready() -> void:
	shock_timer.one_shot = true
	shock_timer.timeout.connect(on_shock)
	add_child(shock_timer)
	on_shock()

func on_shock() -> void:
	shock_clusters(GlobalClass.world.get_clusters())
	boost_neighbors(GlobalClass.world.get_projectiles())
	shock_timer.start(shock_cooldown)

func boost_neighbors(targets: Array[Projectile]) -> void:
	for c in targets:
		if is_instance_valid(c) and c != self and c is ShockProjectile and c.team == team:
			var hitline: HitscanLine = hitscan_line.instantiate()
			hitline.target = c
			add_child(hitline)
			c.shock_cooldown *= peer_cooldown_remove
		await get_tree().create_timer(multishock_interval).timeout

func shock_clusters(targets: Array[Cluster]) -> void:
	var hit_one_target: bool = false
	for c in targets:
		if is_instance_valid(c) and c.team != team:
			var hitline: HitscanLine = hitscan_line.instantiate()
			hitline.target = c
			add_child(hitline)
			
			await get_tree().process_frame
			
			c.recieve_hit(prj_info["dmg_info"])
			hit_one_target = true
		await get_tree().create_timer(multishock_interval).timeout
	if !muted and hit_one_target: 
		GlobalClass.play_sound(hit_sfx)
