extends Part
class_name MeleePart

@onready var melee_area: Area2D = $Area2D

@export var cooldown: float = 0.5
@export var dmg_info: Dictionary = {
	"type": "punch",
	"amount": 1.0,
	"knk": 25.0,
	"duration": 0.0
}

var can_hit: bool = true

func _subready() -> void:
	if !disabled and !editor_mode:
		melee_area.area_entered.connect(hit)

func hit(area: Area2D) -> void: 
	if area is Cluster and user.team != area.team:
		can_hit = false
		area.recieve_hit(dmg_info, global_rotation)
		get_tree().create_timer(cooldown).timeout.connect(set.bind("can_hit", true))
