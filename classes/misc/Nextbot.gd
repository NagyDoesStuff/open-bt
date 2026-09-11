extends Area2D
class_name Nextbox

@export var speed: float = 100.0
@export var acceleration: float = 0.98
@export var damage: float = 999999.0
var velocity: Vector2 = Vector2.ZERO
var chase_offset: Vector2 = Vector2.ZERO

var target: Cluster

func _ready() -> void:
	area_entered.connect(on_col)
	await get_tree().create_timer(3.0).timeout
	get_target()

func on_col(area: Area2D) -> void:
	if area is Cluster:
		area.recieve_hit({
			"type": "dmg",
			"amount": damage
		})

func get_target() -> void:
	target = GlobalClass.world.get_clusters().pick_random()
	target.killed.connect(get_target, ConnectFlags.CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	if target:
		velocity += Vector2.from_angle((target.global_position - global_position).angle()) * speed * delta
	global_position += velocity
	velocity *= acceleration
