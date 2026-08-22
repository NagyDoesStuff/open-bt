extends Part
class_name SpawnerPart

@export_enum("lmb", "space") var keybind: String = "space"
@export var cooldown: float = 10.0
@export var spawned_cluster: PackedScene
@export var spawned_amount: int = 1
@export var limit: int = 1
var can_spawn: bool = true

var spawned_clusters: Array[Cluster] = []

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled: return
	
	if can_spawn:
		if user == GlobalClass.player_cluster:
			if Input.is_action_pressed(keybind):
				spawn()
		else:
			spawn()

func spawn() -> void:
	if get_spawned_cluster_count() == limit: return
	can_spawn = false
	
	for x in range(spawned_amount):
		var cluster: Cluster = spawned_cluster.instantiate()
		cluster.team = user.team
		cluster.force_ai = true
		cluster.force_full_progress = true
		cluster.global_position = global_position
		cluster.global_rotation = randf_range(0, TAU)
		GlobalClass.world.add_child(cluster)
		spawned_clusters.append(cluster)
	
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_spawn", true))

func get_spawned_cluster_count() -> int:
	var amount: int = 0
	for c in spawned_clusters:
		if c: amount += 1
	return amount
