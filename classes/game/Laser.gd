extends RayCast2D
class_name Laser

@export_group("Nodes")
@export var hitscan_line: PackedScene

@export_group("Stats")
@export var laser_range: float = 10000.0
@export var hit_frequency: float = 0.1
@export var dmg_info: Dictionary = {
	"type": "dmg",
	"amount": 0.1,
	"duration": 0.0
}

var can_hit: bool = true

@onready var gun: GunPart = get_parent()
var cooldown_timer: Timer = Timer.new()

var current_target: Node2D

func _ready() -> void:
	add_exception(gun.user)
	target_position = Vector2.RIGHT * laser_range
	collide_with_areas = true
	collide_with_bodies = false
	hit_from_inside = true
	
	cooldown_timer.wait_time = hit_frequency
	cooldown_timer.timeout.connect(on_cooldown_ended)
	add_child(cooldown_timer)

func _process(_delta: float) -> void:
	if !gun.disabled and gun.user.team == 0:
		enabled = Input.is_action_pressed("lmb")
	
	if enabled and !gun.disabled and get_collider():
		hit()

func on_cooldown_ended() -> void:
	if enabled:
		var end_position: Vector2 = to_global(target_position)
		if get_collider():
			end_position = get_collision_point()
		var line: HitscanLine = hitscan_line.instantiate()
		line.origin = self
		line.target_position = end_position
		add_child(line)
	
	can_hit = true

func hit() -> void:
	if get_collider(): current_target = get_collider()
	if !can_hit: return
	can_hit = false
	
	if current_target is Cluster and current_target.team != gun.user.team:
		current_target.recieve_hit(dmg_info)
	elif current_target is Projectile and current_target.team != gun.user.team:
		current_target.get_parent().destroy()
	elif current_target is PoppablePart and current_target.team != gun.user.team:
		current_target.get_parent().destroy()
	
	cooldown_timer.start()
