extends Node2D
class_name GunBarrel

@export var muted: bool = false

# "template" is the projectile scene file
# "dmg_info" types: "dmg", "slowdown" and "jam"
# "target_mode" modes: "default" and "mouse"
# "turn_mode" modes: "default" and "sin"

@export var prj_info: Dictionary = {
	# Normal attributes.
	"template": "uid://cnlneqp8i4qud",
	"dmg_info": {
		"type": "dmg",
		"duration": 0.0,
		"amount": 1.0
	},
	"pierce": false,
	"speed": 2000.0,
	"size": 1.0,
	"hit_fx": "uid://bwddu713otuhv",
	# Homing attributes.
	"homing": false,
	"turn_rate": 10.0,
	"target_mode": "default",
	# Turning attributes.
	"turn_mode": "default",
	"sin_turn_mode_freq": 3.0
}

@export var barrel_user: Node2D

func _ready() -> void:
	if barrel_user and barrel_user is Projectile: return
	else: barrel_user = get_parent()
	if barrel_user.disabled or !barrel_user.user: return
	
	if barrel_user.user.team != 0:
		muted = true

func shoot(power: float = 1.0) -> void:
	if !muted and barrel_user.salvo_interval == 0.0:
		GlobalClass.play_sound(barrel_user.shoot_fx)
	
	for x in range(barrel_user.amount_per_salvo):
		var dupe_info: Dictionary = prj_info.duplicate(true)
		var prj: Projectile = load(prj_info["template"]).instantiate()
		prj.global_rotation = global_rotation + randf_range(-barrel_user.spread, barrel_user.spread)
		prj.team = barrel_user.user.team
		prj.from = barrel_user.user
		
		dupe_info["dmg_info"]["amount"] *= power
		dupe_info["size"] *= power
		prj.prj_info = dupe_info
		
		if dupe_info.has("attached") and dupe_info["attached"] and barrel_user.user is Cluster:
			barrel_user.user.add_child(prj)
		else:
			GlobalClass.world.add_child(prj)
		prj.global_position = global_position
		
		if barrel_user.salvo_interval > 0.0:
			if !muted:
				GlobalClass.play_sound(barrel_user.shoot_fx)
			if is_instance_valid(get_tree()): await get_tree().create_timer(barrel_user.salvo_interval).timeout

func shoot_via_prj() -> void:
	var prj: Projectile = load(prj_info["template"]).instantiate()
	prj.global_position = global_position
	prj.global_rotation = global_rotation
	prj.prj_info = prj_info.duplicate()
	prj.velocity += barrel_user.velocity
	prj.team = barrel_user.team
	prj.from = barrel_user
	GlobalClass.world.add_child(prj)
