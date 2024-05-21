extends Control

var dragging = false
var initial_position = Vector2.ZERO
var drag_offset = Vector2.ZERO  # Amount the module has moved from the origin
var V: float = 1.0  # Input voltage, adjust as needed
var phase: float = 0.0
var frequency_hz: float = 440.0  # Desired frequency of the saw wave

signal wave_generated(wave_data)

# Saw wave properties
var saw_wave_value: float = 0.0
var saw_wave_frequency: float = 1.0  # Base frequency of the saw wave
var saw_wave_max: float = 1.0  # Max value before the wave resets

func _init(_frequency_hz: float = 440.0):
	frequency_hz = _frequency_hz

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

func generate_wave(voltage: float, delta: float):
	var sample_rate: int = 44100 # Assuming CD quality
	var samples_to_generate = int(sample_rate * delta) # Number of samples to generate based on delta
	var buffer = PackedVector2Array() # Wave data buffer
	
	# Calculate the frequency based on the input voltage
	frequency_hz = 440.0 + voltage * 100 # Example voltage to frequency conversion

	# Generate the wave data
	for i in range(samples_to_generate):
		phase += delta * frequency_hz * 2.0 * PI / sample_rate
		if phase > 2.0 * PI:
			phase -= 2.0 * PI
		var sample_value = sin(phase) # Generating a sine wave for simplicity
		buffer.append(Vector2(sample_value, sample_value)) # Add the sample to the buffer
	
	# Emit the signal with the generated wave data
	print(buffer)
	emit_signal("wave_generated", buffer)
