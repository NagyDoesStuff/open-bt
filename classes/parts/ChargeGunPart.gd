extends GunPart
class_name ChargeGunPart

@export var min_power: float = 0.25
@export var max_power: float = 1.0
@export var charge_time: float = 3.0
@export var charge_animation_name: String = "charge"
@export var charge_ready_sfx: String = "uid://dcnojb63afq44"
@export var ai_wait_time_before_release: float = 0.5
@export var laser_hold_time: float = 0.3

var charge_timer: Timer = Timer.new()
var is_charging: bool = false
var charge_start_time: float = 0.0

func _subready() -> void:
	if !user or disabled or !user.enabled: return
	
	barrels = get_barrels()
	
	charge_timer.one_shot = true
	charge_timer.timeout.connect(charge_completed)
	add_child(charge_timer)

func _process(_delta: float) -> void:
	if !user or disabled or !user.enabled or !user.can_fire: return
	
	# Player logic.
	if user == GlobalClass.player_cluster:
		if user.cluster_class >= 4 and !fixed:
			turn_to(get_global_mouse_position(), _delta)
		if Input.is_action_pressed(keybind) and can_shoot and !is_charging:
			start_charge()
		elif Input.is_action_just_released(keybind) and can_shoot and is_charging:
			stop_and_fire()
	# AI Logic.
	elif user.controller.target:
		if !fixed: 
			turn_to(GlobalClass.player_cluster.global_position, _delta)
		if can_shoot:
			start_charge()

func start_charge() -> void:
	if !can_shoot or is_charging: return
	
	if user != GlobalClass.player_cluster:
		can_shoot = false
	
	is_charging = true
	
	charge_start_time = Time.get_ticks_msec() / 1000.0
	
	# Play animation.
	if animation_player: 
		animation_player.play(charge_animation_name)
	
	# Start the timer.
	charge_timer.wait_time = charge_time
	charge_timer.start()

func stop_and_fire() -> void:
	if !can_shoot and user == GlobalClass.player_cluster or !is_charging: return
	
	is_charging = false
	charge_timer.stop()
	
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var elapsed: float = current_time - charge_start_time
	elapsed = min(elapsed, charge_time)
	
	var raw_power: float = elapsed / charge_time
	var final_power: float = clampf(raw_power, min_power, max_power)
	
	fire(final_power)
	
	if animation_player: 
		animation_player.stop()

func charge_completed() -> void:
	var init_modulate: Color = modulate
	modulate *= 1.5
	create_tween().tween_property(self, "modulate", init_modulate, 0.25)
	GlobalClass.play_sound(charge_ready_sfx)
	
	# Fire if AI.
	if user != GlobalClass.player_cluster: 
		await get_tree().create_timer(ai_wait_time_before_release).timeout
		stop_and_fire()
