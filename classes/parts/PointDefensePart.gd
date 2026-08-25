extends Part
class_name PointDefensePart

@export var hitscan_line: PackedScene
@export var hit_fx: PackedScene
@export var hit_range: float = 500.0
@export var cooldown: float = 0.4
@export var turn_time: float = 0.025
var can_defend: bool = true

var area: Area2D = Area2D.new()

func _ready() -> void:
	add_child(area)
	
	var col: CollisionShape2D = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = hit_range
	area.add_child(col)

func _process(_delta: float) -> void:
	if can_defend: defend(area.get_overlapping_areas())

func defend(areas: Array[Area2D]) -> void:
	if !can_defend: return
	can_defend = false
	get_tree().create_timer(cooldown).timeout.connect(set.bind("can_defend", true))
	
	var valid_areas: Array[Projectile]
	for a in areas:
		if a.get_parent() is Projectile and a.get_parent().team != user.team:
			valid_areas.append(a.get_parent())
	if valid_areas.is_empty(): return
	
	var target: Projectile = GlobalClass.get_closest_or_farthest(
		self, 
		valid_areas, 
		true
	)
	
	await create_tween().tween_property(
		self, 
		"global_rotation", 
		(target.global_position - global_position).angle(), 
		turn_time
	).finished
	
	if !target: return
	
	var hitline: HitscanLine = hitscan_line.instantiate()
	hitline.target_position = target.global_position
	add_child(hitline)
	
	var fx: Node2D = hit_fx.instantiate()
	fx.global_position = target.global_position
	GlobalClass.world.add_child(fx)
	
	target.destroy()
