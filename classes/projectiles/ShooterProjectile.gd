extends Projectile
class_name ShooterProjectile

@export var barrels: Array[GunBarrel] = []
@export var cooldown: float = 0.1

func _subready() -> void:
	shoot()

func shoot() -> void:
	if get_tree().paused: return
	for b in barrels:
		b.shoot_via_prj()
	get_tree().create_timer(cooldown).timeout.connect(shoot)
