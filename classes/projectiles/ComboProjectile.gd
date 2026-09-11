extends Projectile
class_name ComboProjectile

@export_group("Combo")
@export var combo_amount: int = 3
@export var combo_tag: String = ""
@export var target_tag: String = ""
@export var destroy_on_combo: bool = false
@export var result_projectile: PackedScene

func _subready() -> void:
	prj_area.area_entered.connect(on_hit_prj)

func on_hit_prj(area: Area2D) -> void:
	var projectile: ComboProjectile
	if area.get_parent() is ComboProjectile:
		projectile = area.get_parent()
	else:
		return
	if target_tag == projectile.combo_tag and result_projectile and combo_amount > 0:
		var result: Projectile = result_projectile.instantiate()
		result.global_position = projectile.global_position
		result.global_rotation = global_rotation
		result.team = team
		GlobalClass.world.call_deferred("add_child", result)
		combo_amount -= 1
		if destroy_on_combo: destroy()
