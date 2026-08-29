extends Node
## No need for a class_name, this is an autoload script.

# PRELOADS
const BUTTON_01: PackedScene = preload("uid://dwlqr56nh4exq")

var PART_BUTTON: PackedScene = load("uid://6d8gvhmdwb87")

const TANK_CHOICE_BUTTON: PackedScene = preload("uid://dk4jicmsok44j")

const BUBBLE_POINT: PackedScene = preload("uid://ckebyrul4e710")

const ARENA_TEMPLATE: PackedScene = preload("uid://dylq1171myx2n")

const DEFAULT_HIT_FX: PackedScene = preload("uid://bwddu713otuhv")

const SCREEN_FLASH: PackedScene = preload("uid://cays5co474q6y")

# CONSTANTS
const ARENA_PUSH_FORCE: int = 100
const DISTANCE_BETWEEN_ARENAS: int = 2000
const DEFAULT_MAX_ENEMIES: int = 6
const MAX_CLASS: int = 6
const UPGRADE_CHOICES: int = 3

const CLUSTER_CHECK_DIST_FREQ: float = .25
const ESTIMATED_ARENA_RADIUS: float = 8505.0 / 2.0
const ARENA_RADIUS_GROW_PER_ENEMY: float = 0.0125
const LAND_ON_ARENA_DIST: float = 0.9
const MIN_BUBBLE_POINT_SIZE: float = 0.33
const BUBBLE_POINT_GROW_SIZE: float = 0.025
const MAX_ENEMIES_INCREMENT_PER_ARENA: float = 0.1
const HIT_BLINK_TIME: float = 0.1


const PARTS_DIRECTORY: String = "res://scenes/parts/"
const INTERNAL_CLUSTERS_DIRECTORY: String = "res://scenes/internal_clusters/"
const CLUSTER_FILES_DIRECTORY: String = "user://tanks/"
const USER_CLUSTERS_DIRECTORY: String = CLUSTER_FILES_DIRECTORY + "user/"
const GAME_CLUSTERS_DIRECTORY: String = CLUSTER_FILES_DIRECTORY + "game/"

const HIT_COLOR: Color = Color(1.164, 1.164, 1.164, 1.0)
const SLOWN_DOWN_COLOR: Color = Color(0.937, 0.8, 1.0, 1.0)
const JAMMED_COLOR: Color = Color(0.8, 1.0, 0.833, 1.0)
const STUNNED_COLOR: Color = Color(0.75, 0.75, 0.75, 0.784)
const INFECTED_COLOR: Color = Color(0.82, 0.279, 0.279, 1.0)
const WEAKENED_COLOR: Color = Color(0.196, 0.144, 0.3, 1.0)
const POISONED_COLOR: Color = Color(0.421, 0.302, 0.72, 1.0)

const DEFAULT_ARENA_SCALE: Vector2 = Vector2.ONE * 0.15

const PROGRESSION_REQUIREMENTS: Array[int] = [
	100, # CLASS 2
	150, # CLASS 3
	250, # CLASS 4 
	400, # CLASS 5
	1000, # CLASS 6
	3000 # MAX
]

const FIXED_BUBBLE_SIZES: Array[int] = [
	1,
	5,
	10,
	100
]

const CLASS_RADIUS: Array[int] = [
	0, # CLASS 1
	90, # CLASS 2
	150, # CLASS 3
	200, # CLASS 4
	270, # CLASS 5
	370 # CLASS 6
]

const UNOVERWRITTABLE_TANK_NAMES: Array[String] = [
	"Basic"
]

const PART_CATEGORIES: Array[String] = [
	"Collision",
	"Player Primaries",
	"Player Secondaries",
	"Player Passives",
	"Enemy Weapons",
	"Enemy Behaviors",
	"Other"
]

# NODES
var world: World
var player_cluster: Cluster
var loaded_clusters: Array[Cluster]
var current_arena: Bubblefield

# VARIABLES
var player_cluster_filename: String = "Basic"
var game_mode: String = "Normal Mode"

var can_pause: bool = true

func _ready() -> void:
	create_directories()
	overwrite_game_clusters()
	load_clusters()

func get_closest_or_farthest(from: Node2D, list: Array, closest: bool) -> Node2D:
	var distance: float
	var best_distance: float = INF
	var best: Node2D = null
	if closest:
		for item: Node2D in list:
			distance = from.global_position.distance_to(item.global_position)
			if distance < best_distance:
				best_distance = distance
				best = item
	else:
		distance = INF
		best_distance = 0.0
		for item: Node2D in list:
			distance = from.global_position.distance_to(item.global_position)
			if distance > best_distance:
				best_distance = distance
				best = item
	return best

func play_sound(
	file_path: String, volume_db: float = 0.0, 
	pitch_scale: float = 1.0, pitch_variation: float = 0.0, 
	volume_variation: float = 0.0, parent: Node = self
) -> AudioStreamPlayer2D:
	if file_path.is_empty(): return
	var pitch: float = pitch_scale + randf_range(-pitch_variation, pitch_variation)
	var vol: float = volume_db + randf_range(-volume_variation, volume_variation)
	var audio_node: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	parent.add_child(audio_node)
	audio_node.stream = load(file_path)
	audio_node.volume_db = vol
	audio_node.pitch_scale = pitch
	audio_node.max_distance = INF
	audio_node.panning_strength = 0.0
	audio_node.process_mode = Node.PROCESS_MODE_ALWAYS
	audio_node.play()
	audio_node.finished.connect(audio_node.queue_free)
	return audio_node

func dice(amount: int, out_of: int) -> bool:
	if randi_range(0, out_of) <= amount:
		return true
	else:
		return false

func freeze_frame(time: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(time).timeout
	get_tree().paused = false

	# func make_dmg_num_text(on: Cluster, dmg: float) -> void:
		# var floating_text: FloatingText = FloatingText.new()
		# floating_text.text = str(int(dmg))
		# floating_text.label_settings = load("res://godot_resources/taunt_label_settings_template.tres").duplicate()
		# floating_text.label_settings.font_color = Color.RED
		# floating_text.global_position = on.global_position
		# floating_text.velocity = on.linear_velocity * global_delta
		# arena.add_child(floating_text)

func get_load_location(cluster: Cluster) -> String:
	for attr in cluster.attributes:
		match attr:
			"game_cluster":
				return GAME_CLUSTERS_DIRECTORY + cluster.name + ".tscn"
			"user_cluster":
				return USER_CLUSTERS_DIRECTORY + cluster.name + ".tscn"
	return ""

func load_clusters() -> void:
	for file in ResourceLoader.list_directory(USER_CLUSTERS_DIRECTORY):
		var cluster: Cluster = load(USER_CLUSTERS_DIRECTORY + file).instantiate()
		cluster.attributes.append("user_cluster")
		loaded_clusters.append(cluster)
	for file in ResourceLoader.list_directory(GAME_CLUSTERS_DIRECTORY):
		var cluster: Cluster = load(GAME_CLUSTERS_DIRECTORY + file).instantiate()
		cluster.attributes.append("game_cluster")
		loaded_clusters.append(cluster)

func create_directories() -> void: 
	if !DirAccess.dir_exists_absolute(GlobalClass.CLUSTER_FILES_DIRECTORY):
		DirAccess.make_dir_absolute(GlobalClass.CLUSTER_FILES_DIRECTORY)
		
	if !DirAccess.dir_exists_absolute(GlobalClass.USER_CLUSTERS_DIRECTORY):
		DirAccess.make_dir_absolute(GlobalClass.USER_CLUSTERS_DIRECTORY)

func overwrite_game_clusters() -> void:
	DirAccess.remove_absolute(GlobalClass.GAME_CLUSTERS_DIRECTORY)
	DirAccess.make_dir_absolute(GlobalClass.GAME_CLUSTERS_DIRECTORY)
	for file in ResourceLoader.list_directory(INTERNAL_CLUSTERS_DIRECTORY):
			ResourceSaver.save(load(INTERNAL_CLUSTERS_DIRECTORY + file), GlobalClass.GAME_CLUSTERS_DIRECTORY + file)

func append_distance_check(who: Node2D) -> void:
	var timer: Timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 0.1
	timer.timeout.connect(func () -> void:
		if GlobalClass.current_arena: 
			who.dist_from_center = who.global_position.distance_to(GlobalClass.current_arena.global_position)
			if who.dist_from_center > GlobalClass.ESTIMATED_ARENA_RADIUS * GlobalClass.current_arena.scale.x:
				who.destroy()
	)
	who.add_child(timer)

func get_gp_increment(cluster_class: int) -> int:
	if cluster_class < 4:
		return 2
	else:
		return 5
