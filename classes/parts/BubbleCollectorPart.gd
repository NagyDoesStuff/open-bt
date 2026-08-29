extends Part
class_name BubbleCollectorPart

@export var cooldown: float = 6.0
@export var collection_range: float = 9999.0
@export var collection_capacity: int = 4

var collection_area: Area2D = Area2D.new()

func _subready() -> void:
	if disabled or !user.enabled or editor_mode: return
	
	var timer: Timer = Timer.new()
	timer.wait_time = cooldown
	timer.autostart = true
	timer.timeout.connect(collect)
	add_child(timer)
	
	add_child(collection_area)
	
	var col: CollisionShape2D = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = collection_range
	collection_area.add_child(col)

func collect() -> void:
	var points_to_steal: Array[BubblePoint] = GlobalClass.world.get_bubble_points().duplicate()
	if points_to_steal.is_empty(): return
	
	points_to_steal.shuffle()
	points_to_steal.resize(collection_capacity)
	
	for p in points_to_steal:
		if !p: break
		p.follow_target = user
		p.force_follow = true
