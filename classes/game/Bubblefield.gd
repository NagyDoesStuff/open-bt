extends Node2D
class_name Bubblefield

var locked: bool = false

func start_spawning() -> void:
	# Boss spawns overwrite normal spawning methods.
	# Search for potential boss candidates.
	var boss_candidates: Array[Cluster] = []
	for c in GlobalClass.loaded_clusters:
		if c.team == -1:
			boss_candidates.append(c)
	for s in GlobalClass.BOSS_SPAWN_INTERVALS:
		if GlobalClass.world.bubblefields_cleared == s["requirement"]:
			# Search for bosses of valid tier.
			var valid_bosses: Array[Cluster] = []
			for c in boss_candidates:
				if c.boss_tier == s["tier"]:
					valid_bosses.append(c)
			if valid_bosses.is_empty(): break
			var boss: Cluster = spawn(valid_bosses.pick_random())
			GlobalClass.world.turn_into_boss(boss)
			boss.global_position = global_position
			resize_arena(0.5 * boss.boss_field_size_mult, true)
			return
	spawn_normally()

func spawn_normally() -> void:
	var enemies_left_to_spawn: int = int(GlobalClass.DEFAULT_MAX_ENEMIES + (GlobalClass.world.bubblefields_cleared * GlobalClass.MAX_ENEMIES_INCREMENT_PER_ARENA))
	if GlobalClass.game_mode == "Beserk Mode":
		enemies_left_to_spawn = 100
	
	var final_spawned: int = 0
	var enemy_names_spawned: Array[String] = []
	
	while enemies_left_to_spawn > 0:
		var enemies: Array[Cluster] = []
		for cluster in GlobalClass.loaded_clusters:
			if cluster.team != GlobalClass.player_cluster.team and cluster.team >= 0 and cluster.min_to_available <= GlobalClass.world.bubblefields_cleared:
				enemies.append(cluster)
		
		if enemies.is_empty(): return
		
		var rand_enemy: Cluster = enemies.pick_random()
		if enemy_names_spawned.has(rand_enemy.name):
			break
		else:
			enemy_names_spawned.append(rand_enemy.name)
		
		var min_enemy_amount: int = 0
		var max_enemy_amount: int = rand_enemy.max_spawn_amount
		
		if rand_enemy.min_to_available == 0:
			min_enemy_amount = 1
		
		if GlobalClass.game_mode == "Beserk Mode":
			min_enemy_amount = max_enemy_amount
		
		for x in randi_range(min_enemy_amount, max_enemy_amount):
			if enemies_left_to_spawn == 0: return
			if !rand_enemy: break
			
			var deployed: Cluster = spawn(rand_enemy)
			if GlobalClass.game_mode == "Beserk Mode":
				deployed.team = randi()
				@warning_ignore("integer_division")
				deployed.drop_value = maxi(1, deployed.drop_value / 2)
				
			enemies_left_to_spawn -= 1
			final_spawned += 1
			resize_arena(final_spawned)

func spawn(cluster: Cluster) -> Cluster:
	var spawned: Cluster = cluster.duplicate()
	spawned.global_position = global_position + Vector2.from_angle(randf_range(0, TAU)) * randf_range(0, GlobalClass.ESTIMATED_ARENA_RADIUS * 0.9 * scale.length() / 2)
	spawned.global_rotation = randf_range(0, TAU)

	for p in spawned.get_parts():
		p.editor_mode = false
		p.disabled = false
			
	GlobalClass.world.add_child(spawned)
	return spawned

func resize_arena(value: float = 1.0, absolute: bool = false) -> void:
	if !absolute:
		scale = GlobalClass.DEFAULT_ARENA_SCALE
		if GlobalClass.game_mode != "Beserk Mode":
			scale += Vector2.ONE * (GlobalClass.ARENA_RADIUS_GROW_PER_ENEMY * value)
		else:
			scale += Vector2.ONE * (GlobalClass.ARENA_RADIUS_GROW_PER_ENEMY * value) / 2
	else:
		scale = Vector2.ONE * value
