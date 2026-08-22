extends Node2D
class_name Projectile

@onready var player_spr: Sprite2D = $PLAYER
@onready var other_spr: Sprite2D = $OTHER

var sprites: Array[Sprite2D] = []

var dist_from_center: float = 0.0
var init_rot: float = 0.0

var team: int = 0
var velocity: Vector2 = Vector2.ZERO
@export var prj_info: Dictionary = {}

var target: Cluster
var from: Cluster
@onready var prj_area: Area2D = $Area2D

@export var lifetime: float = -1.0

@export var phase: bool = false

@export var spin_rate: float = 0.0

@export_group("Splitting")
@export var split_into: PackedScene
@export var split_radius: float = 10.0
@export var split_amount: int = 1
## does nothing for now
@export_enum("destroyed", "expired") var split_on: String = "destroyed"

@export_group("Audio")
@export var muted: bool = false
@export var hit_sfx: String = "uid://br055er0cj176"

func _ready() -> void:
	scale = Vector2.ONE * prj_info["size"]
	init_rot = global_rotation
	
	if !phase: prj_area.area_entered.connect(on_hit, ConnectFlags.CONNECT_DEFERRED)
	
	if team == 0: other_spr.queue_free()
	else: player_spr.queue_free()
	
	if prj_info.has("homing") and prj_info["homing"]:
		search_for_target()
	
	if lifetime > 0.0:
		get_tree().create_timer(lifetime).timeout.connect(destroy)
	
	GlobalClass.append_distance_check(self)
	
	sprites = await get_sprites()
	
	_subready()

func _subready() -> void:
	pass

var t: float = randf_range(0.0, 1.0)
func _process(delta: float) -> void:
	t += delta
	
	velocity = Vector2.from_angle(global_rotation) * prj_info["speed"] * delta
	global_position += velocity
	
	if prj_info.has("homing") and prj_info["homing"] and target and prj_info.has("turn_rate") and prj_info.has("target_mode"):
		follow_target(prj_info["target_mode"], delta)
	elif prj_info.has("homing") and prj_info["homing"] and target and prj_info.has("turn_rate"):
		follow_target("default", delta)
	
	if prj_info.has("turn_rate") and prj_info.has("turn_mode") and prj_info["turn_mode"] == "sin" and prj_info.has("sin_turn_mode_freq"):
		global_rotation = init_rot + sin(t * prj_info["sin_turn_mode_freq"]) * prj_info["turn_rate"]
	
	for spr in sprites:
		spr.global_rotation += spin_rate * delta
	
func on_hit(area: Area2D) -> void:
	if area is Cluster and area.team != team: 
		area.recieve_hit(prj_info["dmg_info"])
		if !muted: GlobalClass.play_sound(hit_sfx)
		if prj_info.has("pierce") and !prj_info["pierce"]: return
		destroy()
	if area.get_parent() is Projectile and area.get_parent().team != team and area.get_parent().prj_info.has("homing") and area.get_parent().prj_info["homing"]:
		area.get_parent().destroy()
		if prj_info.has("pierce") and !prj_info["pierce"]: return
		destroy()
	if area.get_parent() is PoppablePart and area.get_parent().user.team != team:
		area.get_parent().destroy()
		if prj_info.has("pierce") and !prj_info["pierce"]: return
		destroy()

func destroy() -> void:
	if split_into:
		for x in range(split_amount):
			var split_result: Node2D = split_into.instantiate()
			split_result.global_position = global_position + Vector2.RIGHT.rotated(randf_range(0, TAU)) * split_radius * scale
			split_result.global_rotation = x * (TAU / split_amount)
			split_result.team = team
			GlobalClass.world.add_child(split_result)
	
	var fx: Node2D
	if prj_info.has("hit_fx"):
		fx = load(prj_info["hit_fx"]).instantiate()
	else:
		fx = GlobalClass.DEFAULT_HIT_FX.instantiate()
	fx.global_position = global_position
	fx.scale = scale
	GlobalClass.world.add_child(fx)
	
	call_deferred("queue_free")
	
func search_for_target() -> void:
	# Slight delay so the target isnt the same as the one killed.
	await get_tree().process_frame
	
	var enemies: Array[Cluster] = []
	
	for c in GlobalClass.world.get_clusters():
		if c.team != team:
			enemies.append(c)
	
	if enemies.is_empty(): 
		destroy()
		return
	
	target = enemies.pick_random()
	target.killed.connect(search_for_target, ConnectFlags.CONNECT_ONE_SHOT)

func follow_target(mode: String, delta: float) -> void:
	if !target: return
	match mode:
		"default":
			global_rotation = lerp_angle(
				global_rotation,
				(target.global_position - global_position).angle(),
				delta * prj_info["turn_rate"]
			)
		"mouse":
			global_rotation = lerp_angle(
				global_rotation,
				(get_global_mouse_position() - global_position).angle(),
				delta * prj_info["turn_rate"]
			)

func get_sprites() -> Array[Sprite2D]:
	await get_tree().process_frame
	var list: Array[Sprite2D] = []
	
	for spr in get_children():
		if spr is Sprite2D:
			list.append(spr)
	
	return list
