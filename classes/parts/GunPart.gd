extends Part
class_name GunPart

@export var turn_rate: float = 20.0
@export var cooldown: float = 0.5
@export var shoot_fx: String = "uid://dfx02l3ac3xjd"
@export var spread: float = 0.0
@export var shot_delay: float = 0.0
@export var amount_per_salvo: int = 1
@export var salvo_interval: float = 0.0
@export_enum(
	"lmb",
	"space"
) var keybind: String = "lmb"
@export var fixed: bool = false
@export var auto_shoot: bool = false
var can_shoot: bool = true

@export var full_turn_amount: int = 0

@export_group("Visual")
@export var shot_animation: String = "shot"
@export var animation_player: AnimationPlayer

var barrels: Array[GunBarrel]
var lasers: Array[Laser]

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	
	barrels = get_barrels()

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled: return
	
	if user == GlobalClass.player_cluster:
		if user.cluster_class >= 4 and !fixed:
			turn_to(get_global_mouse_position(), _delta)
		if can_shoot and Input.is_action_pressed(keybind) or can_shoot and auto_shoot:
			fire_all_barrels()
	elif user.team != 0 and user.controller and user.controller.target:
		if !fixed: 
			turn_to(user.controller.target.global_position, _delta)
		if can_shoot: fire_all_barrels()

func get_barrels() -> Array[GunBarrel]:
	var list: Array[GunBarrel] = []
	for c in get_children():
		if c is GunBarrel:
			list.append(c)
	return list
	
func fire_all_barrels() -> void:
	can_shoot = false
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_shoot", true))
	if animation_player: animation_player.play(shot_animation)
	await get_tree().create_timer(shot_delay).timeout
	
	for b in barrels:
		b.shoot()
		
	for x in range(full_turn_amount):
		await create_tween().tween_property(self, "rotation", TAU, amount_per_salvo * salvo_interval).finished
		rotation = init_rotation

func turn_to(pos: Vector2, delta: float) -> void:
	global_rotation = rotate_toward(
		global_rotation,
		(pos - global_position).angle(),
		turn_rate * delta
	)
