extends Projectile
class_name SapperProjectile

@export var stolen_health_ratio: float = 1.0
@export var idle_animation_name: String = "idle"
@export var returning_animation_name: String = "return"
@export var animation_player: AnimationPlayer

var stolen_health: int = 0

func _subready() -> void:
	animation_player.play(idle_animation_name)

func _process(delta: float) -> void:
	t += delta
	
	velocity = Vector2.from_angle(global_rotation) * prj_info["speed"] * delta
	global_position += velocity
	
	follow_target("default", delta)
	
	for spr in sprites:
		spr.global_rotation += spin_rate * delta

func on_hit(area: Area2D) -> void:
	if area is Cluster:
		if area.team != team: 
			area.recieve_hit(prj_info["dmg_info"])
			stolen_health = int(prj_info["dmg_info"]["amount"] * stolen_health_ratio)
			target = from
			animation_player.play(returning_animation_name)
			if !muted: 
				GlobalClass.play_sound(hit_sfx)
		elif from:
			from.progress += stolen_health
			destroy()
		else: destroy()
