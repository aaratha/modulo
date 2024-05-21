extends Control

var dragging = false
var initial_position = Vector2.ZERO
var drag_offset = Vector2.ZERO  # Amount the module has moved from the origin

func _ready():
	initial_position = position

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var non_draggable_nodes = get_tree().get_nodes_in_group("ports")
			var is_over_non_draggable = false
			for node in non_draggable_nodes:
				if node.get_rect().has_point(get_local_mouse_position()):
					is_over_non_draggable = true
					break
			if not is_over_non_draggable:
				dragging = true
				return true  # Mark the event as handled
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position += event.relative
		drag_offset = position - initial_position
		return true  # Mark the event as handled
	return true  # Always return true at the end
