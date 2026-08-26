extends Node2D
class_name Controller

@onready var user: Cluster = get_parent()
var enabled: bool = false

func _ready() -> void:
	_subready()
	
func _subready() -> void:
	pass
