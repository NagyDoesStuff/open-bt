extends Node
class_name StatusEffectManager

@onready var cluster: Cluster = get_parent()

var is_slown_down: bool = false
var is_weakened: bool = false
var health_drain: float = -1.0

func _process(_delta: float) -> void:
	if health_drain > 0.0:
		cluster.progress -= health_drain

func slow_down(mult: float, duration: float, with_color: bool = true) -> void:
	if is_slown_down: return
	is_slown_down = true
	
	var init_speed: float = cluster.speed
	var init_turn_rate: float = cluster.turn_rate
	cluster.speed *= mult
	cluster.turn_rate *= mult
	
	if with_color: cluster.modulate = GlobalClass.SLOWN_DOWN_COLOR
	
	await get_tree().create_timer(duration).timeout
	
	if with_color: cluster.modulate = Color.WHITE
	
	cluster.speed = init_speed
	cluster.turn_rate = init_turn_rate
	is_slown_down = false

func jam_weapons(duration: float, with_color: bool = true) -> void:
	if cluster.can_fire: return
	cluster.can_fire = true
	
	if with_color: cluster.modulate = GlobalClass.JAMMED_COLOR
	
	await get_tree().create_timer(duration).timeout
	
	if with_color: cluster.modulate = Color.WHITE
	
	cluster.can_fire = false

func stun(duration: float) -> void:
	slow_down(0.0, duration, false)
	jam_weapons(duration, false)
	
	cluster.modulate = GlobalClass.STUNNED_COLOR
	
	await get_tree().create_timer(duration).timeout
	
	cluster.modulate = Color.WHITE

func weaken(dmg_taken: float, duration: float, with_color: bool = true) -> void:
	if is_weakened: return
	is_weakened = true
	
	var init_damage_taken: float = cluster.damage_taken
	cluster.damage_taken = dmg_taken
	
	if with_color: cluster.modulate = GlobalClass.WEAKENED_COLOR
	
	await get_tree().create_timer(duration).timeout
	
	if with_color: cluster.modulate = Color.WHITE
	
	cluster.speed = init_damage_taken
	is_weakened = false

func poison(amount: float, duration: float, with_color: bool = true) -> void:
	if health_drain > 0.0: return
	health_drain = amount
	
	if with_color: cluster.modulate = GlobalClass.POISONED_COLOR
	
	await get_tree().create_timer(duration).timeout
	
	if with_color: cluster.modulate = Color.WHITE
	
	health_drain = -1.0
