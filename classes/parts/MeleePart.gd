extends Part
class_name MeleePart

@onready var melee_area: Area2D = $Area2D

@export_group("Stats")
@export var cooldown: float = 0.5
@export var dmg_info: Dictionary = {
	"type": "punch",
	"amount": 1.0,
	"knk": 25.0,
	"duration": 0.0
}
@export var instakill_class: int = 0

@export_group("Visual")
@export var attack_animation: String = "atk"
@export var animation_player: AnimationPlayer

var can_hit: bool = true

func _subready() -> void:
	if !disabled and !editor_mode:
		melee_area.area_entered.connect(hit)

func hit(area: Area2D) -> void: 
	if area is Cluster and user.team != area.team and can_hit:
		if area != GlobalClass.player_cluster and area.cluster_class <= instakill_class:
			area.kill()
		else:
			area.recieve_hit(dmg_info, global_rotation)
		
		if animation_player:
			animation_player.play(attack_animation)
		
		can_hit = false
		get_tree().create_timer(cooldown).timeout.connect(set.bind("can_hit", true))
