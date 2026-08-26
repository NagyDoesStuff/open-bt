extends Part
class_name HealerPart

@export var hitscan_line: PackedScene
@export var hit_fx: PackedScene

@export var turn_rate: float = 6.0
@export var search_cooldown: float = 1.0
@export var search_target_hp_ratio: float = 0.9

@export var heal_cooldown: float = 0.25
@export var heal_amount: float = 1.0

var crr_helping: Cluster
var heal_timer: Timer = Timer.new()

func _ready() -> void:
	var search_timer: Timer = Timer.new()
	search_timer.autostart = true
	search_timer.wait_time = search_cooldown
	search_timer.timeout.connect(search_for_hurt)
	add_child(search_timer)
	
	heal_timer.wait_time = heal_cooldown
	heal_timer.timeout.connect(heal)
	add_child(heal_timer)

func _process(delta: float) -> void:
	if crr_helping:
		global_rotation = rotate_toward(
			global_rotation,
			(crr_helping.global_position - global_position).angle(),
			delta * turn_rate
		)
	else:
		global_rotation = rotate_toward(
			global_rotation,
			user.global_rotation,
			delta * turn_rate
		)

func search_for_hurt() -> void:
	var valid_clusters: Array[Cluster] = []
	for c in GlobalClass.world.get_clusters():
		if c != user and c.team == user.team and c.progress < c.max_progress * search_target_hp_ratio:
			valid_clusters.append(c)
	crr_helping = GlobalClass.get_closest_or_farthest(self, valid_clusters, true)
	if crr_helping: heal_timer.start()

func heal() -> void:
	if !crr_helping: return
	
	var hitline: HitscanLine = hitscan_line.instantiate()
	hitline.target_position = crr_helping.global_position
	add_child(hitline)
	
	var fx: Node2D = hit_fx.instantiate()
	fx.global_position = crr_helping.global_position
	GlobalClass.world.add_child(fx)
	
	crr_helping.progress += heal_amount
