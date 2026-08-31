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

@export_group("Other")
@export var is_clonable: bool = true

var barrels: Array[GunBarrel]
var lasers: Array[Laser]

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	update_barrels()
	update_lasers()

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled or !user.can_fire: return
	
	if user == GlobalClass.player_cluster:
		if user.cluster_class >= 4 and !fixed:
			turn_to(get_global_mouse_position(), _delta)
		if can_shoot and Input.is_action_pressed(keybind) or can_shoot and auto_shoot:
			fire()
		toggle_lasers(Input.is_action_pressed(keybind))
	elif user.team != 0 and user.controller and user.controller.target:
		if !fixed: 
			turn_to(user.controller.target.global_position, _delta)
		if can_shoot: fire()
		if full_turn_amount == 0: toggle_lasers(true)

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

func fire(power: float = 1.0) -> void:
	enter_cooldown()
	
	if is_instance_valid(animation_player) and animation_player.has_animation(shot_animation): 
		animation_player.play(shot_animation)
	
	if shot_delay > 0.0:
		await get_tree().create_timer(shot_delay).timeout
	
	for b in barrels:
		b.shoot(power)
	
	if full_turn_amount > 0:
		spin()

func enter_cooldown() -> void:
	can_shoot = false
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_shoot", true))

func spin() -> void:
	toggle_lasers(true)
	for x in range(full_turn_amount):
		await create_tween().tween_property(self, "rotation", TAU, amount_per_salvo * salvo_interval).finished
		rotation = init_rotation
	toggle_lasers(false)

func turn_to(pos: Vector2, delta: float) -> void:
	global_rotation = rotate_toward(
		global_rotation,
		(pos - global_position).angle(),
		turn_rate * delta
	)

func update_barrels() -> void:
	barrels = get_barrels()

func update_lasers() -> void:
	lasers = get_lasers()

func toggle_lasers(value: bool) -> void:
	for l in get_lasers():
		l.enabled = value
