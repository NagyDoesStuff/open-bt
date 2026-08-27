extends Projectile
class_name OrbitalSeekerProjectile

@export var activate_animation_name: String = "activate"
@export var sensor_radius: float = 150.0
@export var orbit_rate: float = 4.0
var orbit_margin: float = 20.0

var activated: bool = false

func _subready() -> void:
	var activate_area: Area2D = Area2D.new()
	activate_area.set_collision_layer_value(1, false)
	activate_area.set_collision_mask_value(1, false)
	activate_area.set_collision_layer_value(2, true)
	activate_area.set_collision_mask_value(2, true)
	activate_area.area_entered.connect(activate)
	add_child(activate_area)
	
	var activate_col: CollisionShape2D = CollisionShape2D.new()
	activate_col.shape = CircleShape2D.new()
	activate_col.shape.radius = sensor_radius
	activate_area.add_child(activate_col)
	
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.5)

func _process(delta: float) -> void:
	t += delta
	if activated: 
		velocity = Vector2.from_angle(global_rotation) * prj_info["speed"] * delta
		follow_target("default", delta)
		global_position += velocity
		velocity *= acceleration
	elif from:
		var next_position: Vector2 = from.global_position + Vector2.from_angle(t * orbit_rate) * (GlobalClass.CLASS_RADIUS[from.cluster_class] + orbit_margin)
		global_rotation = (next_position - global_position).angle()
		global_position = next_position

func activate(area: Node2D) -> void:
	if area is Cluster and area.team != team and !activated:
		activated = true
		if animation_player: animation_player.play(activate_animation_name)

func lifetime_ran_out() -> void:
	if activated: return
	destroy()
