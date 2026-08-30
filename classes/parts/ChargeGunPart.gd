extends GunPart
class_name ChargeGunPart

@export var charge_time: float = 3.0
@export var charge_animation_name: String = "charge"
@export var charge_ready_sfx: String = "uid://dcnojb63afq44"
@export var ai_wait_time_before_release: float = 0.5
@export var laser_hold_time: float = 0.3

var charge_timer: Timer = Timer.new()

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	
	barrels = get_barrels()
	
	charge_timer.one_shot = true
	charge_timer.timeout.connect(complete_charge)
	add_child(charge_timer)
	
	if user == GlobalClass.player_cluster:
		can_shoot = false

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled or !user.can_fire: return
	
	if user == GlobalClass.player_cluster:
		if user.cluster_class >= 4 and !fixed:
			turn_to(get_global_mouse_position(), _delta)
		if Input.is_action_just_pressed(keybind) and !can_shoot:
			charge()
		if Input.is_action_just_released(keybind):
			if !can_shoot:
				cancel_charge()
			else:
				fire()
	elif GlobalClass.player_cluster:
		if !fixed: 
			turn_to(GlobalClass.player_cluster.global_position, _delta)
		if can_shoot:
			charge()

func charge() -> void:
	if user.team != 0: can_shoot = false
	if animation_player: animation_player.play(charge_animation_name)
	charge_timer.start(charge_time)

func complete_charge() -> void:
	var init_modulate: Color = modulate
	modulate *= 1.5
	create_tween().tween_property(self, "modulate", init_modulate, 0.25)
	
	GlobalClass.play_sound(charge_ready_sfx)
	
	if user == GlobalClass.player_cluster:
		can_shoot = true
	else:
		await get_tree().create_timer(ai_wait_time_before_release).timeout
		fire()

func cancel_charge() -> void:
	if user.team != 0: can_shoot = true
	animation_player.stop()
	charge_timer.stop()

func fire() -> void:
	can_shoot = false
	if animation_player and animation_player.has_animation(shot_animation): animation_player.play(shot_animation)
	cancel_charge()
	
	await get_tree().create_timer(shot_delay).timeout
	
	for b in barrels:
		b.shoot()
	
	toggle_lasers(true)
	get_tree().create_timer(laser_hold_time).timeout.connect(toggle_lasers.bind(false))
		
	for x in range(full_turn_amount):
		await create_tween().tween_property(self, "rotation", TAU, amount_per_salvo * salvo_interval).finished
		rotation = init_rotation
