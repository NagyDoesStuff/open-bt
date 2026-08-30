extends Projectile
class_name ProximityMineProjectile

@export var sensor_radius: float = 300.0
@export var explode_delay: float = 0.5

func _subready() -> void:
	var activate_area: Area2D = Area2D.new()
	activate_area.set_collision_layer_value(1, false)
	activate_area.set_collision_mask_value(1, false)
	activate_area.set_collision_layer_value(2, true)
	activate_area.set_collision_mask_value(2, true)
	activate_area.area_entered.connect(detonate)
	add_child(activate_area)
	
	var activate_col: CollisionShape2D = CollisionShape2D.new()
	activate_col.shape = CircleShape2D.new()
	activate_col.shape.radius = sensor_radius
	activate_area.add_child(activate_col)
	
	velocity += Vector2.from_angle(global_rotation) * prj_info["speed"]

func detonate(area: Area2D) -> void:
	if area is Cluster and area.team != team:
		await get_tree().create_timer(explode_delay).timeout
		destroy()

func _process(_delta: float) -> void:
	if !GlobalClass.current_arena: return
	
	global_position += velocity
	velocity *= acceleration
