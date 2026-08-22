extends Part
class_name GunPart

@export var turn_rate: float = 20.0
@export var cooldown: float = 0.5
@export var shoot_fx: String = "uid://dfx02l3ac3xjd"
@export var spread: float = 0.0
@export var amount_per_salvo: int = 1
@export var salvo_interval: float = 0.0
@export_enum(
	"lmb",
	"space"
) var keybind: String = "lmb"
@export var fixed: bool = false
var can_shoot: bool = true

@export var full_turn_amount: int = 0

var barrels: Array[GunBarrel]
var lasers: Array[Laser]

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	
	barrels = get_barrels()
	lasers = get_lasers()

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled: return
	
	if user == GlobalClass.player_cluster:
		if user.cluster_class >= 4 and !fixed:
			turn_to(get_global_mouse_position(), _delta)
		if can_shoot and Input.is_action_pressed(keybind):
			fire_all_barrels()
	elif GlobalClass.player_cluster:
		if !fixed: 
			turn_to(GlobalClass.player_cluster.global_position, _delta)
		if can_shoot: fire_all_barrels()

func get_barrels() -> Array[GunBarrel]:
	var list: Array[GunBarrel] = []
	for c in get_children():
		if c is GunBarrel:
			list.append(c)
	return list

func get_lasers() -> Array[Laser]:
	var list: Array[Laser] = []
	for c in get_children():
		if c is Laser:
			list.append(c)
	return list
	
func fire_all_barrels() -> void:
	can_shoot = false
	for b in barrels:
		b.shoot()
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_shoot", true))
	for x in range(full_turn_amount):
		await create_tween().tween_property(self, "rotation", TAU, amount_per_salvo * salvo_interval).finished
		rotation = init_rotation

func turn_to(pos: Vector2, delta: float) -> void:
	global_rotation = lerp_angle(
		global_rotation,
		(pos - global_position).angle(),
		turn_rate * delta
	)
