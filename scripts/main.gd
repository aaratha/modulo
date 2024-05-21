extends Node2D

var module = load("res://scenes/module.tscn")
var oscillator = load("res://scenes/oscillator.tscn")
var ropeScene = preload("res://scenes/rope.tscn")  # Preload the rope scene

var tethering = false
var start_port = null

var links = []

var port_offset = Vector2(10,10)

func _ready():
	var send = get_node("send")
	send.add_to_group("ports")
	var receive = get_node("receive")
	receive.add_to_group("ports")

func _on_add_module_pressed():
	var module_instance = module.instantiate()
	add_child(module_instance)
	update_ports()

func _on_add_oscillator_pressed():
	var module_instance = oscillator.instantiate()
	add_child(module_instance)
	update_ports()

func update_ports():
	for port in get_tree().get_nodes_in_group("ports"):
		port.pressed.connect(_on_port_pressed.bind(port))

func _on_port_pressed(port):
	print("Port pressed")
	if not tethering:
		tethering = true
		start_port = port
		var rope_instance = ropeScene.instantiate()
		get_tree().root.add_child(rope_instance)
		rope_instance.set_start(port.global_position + port_offset)
		rope_instance.set_last(get_global_mouse_position())  # Initial end point is mouse position
		links.append([port, null, rope_instance])
	else:
		tethering = false
		var last_link = links[-1]
		last_link[1] = port  # Set the end port of the last link
		last_link[2].set_last(port.global_position + port_offset)  # Update the end position of the rope

func _process(delta):
	if tethering and links.size() > 0:
		var last_link = links[-1]  # Get the last link, which is currently being tethered
		var rope_instance = last_link[2]  # The rope instance is the third item in the link array
		rope_instance.set_last(get_global_mouse_position() + port_offset)  # Update rope's end to follow the mouse
	else:
		for link in links:
			if link[1] != null:  # If the link has both start and end ports
				link[2].set_start(link[0].global_position + port_offset)
				link[2].set_last(link[1].global_position + port_offset)
