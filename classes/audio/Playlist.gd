extends Node
class_name Playlist

@export var can_repeat: bool = true
@export var tracks: Array[String] = []
@onready var current: String = tracks.pick_random()

func _ready() -> void:
	pick_music()

func pick_music() -> void:
	await get_tree().process_frame
	var available_options: Array[String] = tracks
	if !can_repeat: available_options.erase(current)
	current = tracks.pick_random()
	var player: AudioStreamPlayer2D = GlobalClass.play_sound(current, 0.0, 1.0, 0.0, 0.0, self)
	if player: player.finished.connect(pick_music)
