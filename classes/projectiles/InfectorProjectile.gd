extends Projectile
class_name InfectorProjectile

@export var duplicate_amount: int = 2
@export var hp_drain_frequency: float = 1.0
var infecting: Cluster 

func _subready() -> void:
	var drain_hp_timer: Timer = Timer.new()
	drain_hp_timer.autostart = true
	drain_hp_timer.wait_time = hp_drain_frequency
	drain_hp_timer.timeout.connect(drain_hp)
	add_child(drain_hp_timer)

func drain_hp() -> void:
	if !infecting: return
	infecting.recieve_hit(prj_info["dmg_info"])

func infect(cluster: Cluster) -> void:
	var init_infected_mod: Color = cluster.modulate
	
	infecting = cluster
	infecting.modulate = GlobalClass.INFECTED_COLOR
	destroyed.connect(infecting.set.bind("modulate", init_infected_mod))
	infecting.killed.connect(
		func () -> void:
			mitosis()
			await get_tree().process_frame
			destroy()
	)
	
	# Dissapear.
	prj_area.monitoring = false
	prj_area.monitorable = false
	hide()

func _process(delta: float) -> void:
	t += delta
	
	if !infecting: 
		velocity = Vector2.from_angle(global_rotation) * prj_info["speed"] * delta
		global_position += velocity
		follow_target("default", delta)
	else:
		global_position = infecting.global_position

func on_hit(area: Area2D) -> void:
	if area is Cluster and area.team != team:
		infect(area)
		if !muted: 
			GlobalClass.play_sound(hit_sfx)

func mitosis() -> void:
	for x in range(duplicate_amount):
		var dupe: Projectile = self.duplicate()
		dupe.global_rotation = x * (TAU / split_amount)
		dupe.team = team
		GlobalClass.world.add_child(dupe)
		
		dupe.show()
		dupe.prj_area.monitoring = true
