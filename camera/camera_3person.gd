extends Node3D
class_name Camera3Person

@export var mouse_sensitivity := 0.002
@export var min_pitch_deg := -85.0
@export var max_pitch_deg := 85.0



var _yaw := 0.0    # around Y (left/right)
var _pitch := 0.0  # around X (up/down)

@onready var min_pitch_rad := deg_to_rad(min_pitch_deg)    # around Y (left/right)
@onready var max_pitch_rad := deg_to_rad(max_pitch_deg) # around X (up/down)
@onready var pivot = get_parent()

func _ready() -> void:
	# Capture the mouse so movement is continuous.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch += event.relative.y * mouse_sensitivity
		# Clamp vertical angle so we don't flip over the top.
		_pitch = clamp(_pitch, min_pitch_rad, max_pitch_rad)
		# Apply rotation: X = pitch, Y = yaw, Z = 0 to avoid roll.
		pivot.rotation = Vector3(_pitch, _yaw, 0.0)
	# Optional: press Esc to release mouse capture
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			
		
		
		
