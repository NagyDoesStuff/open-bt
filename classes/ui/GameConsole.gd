extends Panel
class_name GameConsole

# NODES
@onready var input_box: LineEdit = $MarginContainer/VBoxContainer/InputBox
@onready var log_container: VBoxContainer = $MarginContainer/VBoxContainer/Panel/MarginContainer/ScrollContainer/VBoxContainer

# VARIABLESz
@export var debug: bool = false
var active: bool = false

func _ready() -> void:
	if GlobalClass.game_mode != "Developer Mode":
		hide()
	else:
		active = true
		log_open()

func _input(_event: InputEvent) -> void:
	if !active: return
	
	if Input.is_action_just_pressed("console_toggle"):
		visible = !visible
	
	if Input.is_action_just_pressed("enter"):
		submit_cmd(input_box.text)

func submit_cmd(text: String) -> void:
	if text.is_empty(): return
	
	var text_array: PackedStringArray = text.split(" ", false, 99)
	if text_array.is_empty(): return
	
	var cmd: String = text_array[0]
	var args: PackedStringArray = text_array.duplicate()
	args.remove_at(0)
	
	read_command(cmd, args)
	
	input_box.text = ""

func read_command(cmd: String, args: Array[String]) -> void:
	print("Inserted command: " + cmd)
	print("Inserted argument: " + str(args))
	
	match cmd:
		"clear":
			clear_console()
		"transform":
			if !args.is_empty():
				var result: Cluster = get_cluster_from_loaded(args[0])
				if !is_instance_valid(result):
					console_log(args[0] + " isnt a valid cluster name !")
					return
				GlobalClass.world.transform_player_into(get_cluster_from_loaded(args[0]))
				console_log("Successfully transformed the player into " + args[0] + " !")
			else:
				console_log("No cluster names provided for command '" + cmd + "'!")
		"spawn":
			if !args.is_empty():
				var result: Cluster = get_cluster_from_loaded(args[0])
				if !is_instance_valid(result):
					console_log(args[0] + " isnt a valid cluster name!")
					return
				if args.size() < 2:
					console_log("No team id provided !")
					return
				if args.size() < 3:
					console_log("No amount provided !")
					return
				for i in range(int(args[2])):
					GlobalClass.world.spawn_cluster(result.duplicate(), int(args[1]))
				console_log("Successfully spawned " + args[0] + " on team " + args[1] + " (x" + args[2] + ") !")
			else:
				console_log("No cluster names provided for command '" + cmd + "'!")
		"killall":
			for c in GlobalClass.world.get_clusters():
				if c != GlobalClass.player_cluster:
					c.kill()
			console_log("Successfully killed all tanks!")
		"settravelled":
			if !args.is_empty():
				GlobalClass.world.arenas_travelled = int(args[0])
				console_log("Set bubblefields travelled to " + args[0] + " !")
			else:
				console_log("No value provided for command '" + cmd + "'!")
		"setbfsize":
			if !args.is_empty():
				GlobalClass.current_arena.scale = GlobalClass.DEFAULT_ARENA_SCALE * float(args[0])
				console_log("Set the bubblefield's size to " + args[0] + " !")
			else:
				console_log("No size provided for command '" + cmd + "'!")
		"help":
			log_instructions()
		"cinfo":
			console_log("")
			console_log("------------------------------------------------------")
			console_log("LOADED CLUSTERS INFO")
			console_log("")
			for c in GlobalClass.loaded_clusters:
				if c.team == 0:
					console_log("- " + c.name + " (player tank)")
				elif c.team == 1:
					console_log("- " + c.name + " (enemy tank)")
				else:
					console_log("- " + c.name + " (team id " + str(c.team) + ")")
			console_log("------------------------------------------------------")
			console_log("")
		_:
			console_log("There is no such command as '" + cmd + "'!")

func get_cluster_from_loaded(text: String) -> Cluster:
	for p in GlobalClass.loaded_clusters:
		if p.name == text:
			return p.duplicate()
	return null

func console_log(value: String) -> void:
	var label: Label = GlobalClass.CONSOLE_LOG_LABEL.instantiate()
	label.text = value
	log_container.add_child(label)

func clear_console() -> void:
	for l in log_container.get_children():
		l.queue_free()
	log_open()

func log_open() -> void:
	console_log("------------------------------------------------------")
	console_log("")
	console_log("Welcome to the OpenBT console !")
	console_log("Type 'help' to display commands.")
	console_log("")
	console_log("------------------------------------------------------")
	console_log("")

func log_instructions() -> void:
	console_log("")
	console_log("------------------------------------------------------")
	console_log("")
	console_log("- clear: removes all text in the console")
	console_log("")
	console_log("- transform [name]: changes your tank into the one specified by name (case sensitive)")
	console_log("")
	console_log("- spawn [name] [team id] [amount]: creates a tank of the specified name")
	console_log("")
	console_log("- killall: kills all tanks (player excluded)")
	console_log("")
	console_log("- settravelled [value]: sets the amount of bubblefields traveled")
	console_log("")
	console_log("- setbfsize [value]: sets the size of the current bubblefield")
	console_log("")
	console_log("- cinfo [value]: logs the loaded cluster names and teams")
	console_log("")
	console_log("------------------------------------------------------")
	console_log("")
