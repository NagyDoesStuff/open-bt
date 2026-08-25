extends Projectile
class_name SeekerMineProjectile

@export var activate_animation_name: String = "activate"
@export var sensor_radius: float = 200.0
var activated: bool = false

func _subready() -> void:
	var activate_area: Area2D = Area2D.new()
	activate_area.area_entered.connect(activate)
	add_child(activate_area)
	
	var activate_col: CollisionShape2D = CollisionShape2D.new()
	activate_col.shape = CircleShape2D.new()
	activate_col.shape.radius = sensor_radius
	activate_area.add_child(activate_col)

func _process(delta: float) -> void:
	if activated: 
		velocity = Vector2.from_angle(global_rotation) * prj_info["speed"] * delta
		follow_target("default", delta)
	global_position += velocity
	velocity *= acceleration

func activate(area: Node2D) -> void:
	if area is Cluster and area.team != team and !activated:
		activated = true
		animation_player.play(activate_animation_name)
