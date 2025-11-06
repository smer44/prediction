extends AnimatableBody3D
class_name PathFollower3D


signal path_finished   # Emitted when the last point is reached in non-looping mode

@export var speed: float = 5.0
@export var loop: bool = true
@export var snap_to_first_point: bool = false      # If true, start exactly at the first point
@export var arrive_radius: float = 0.05            # How close counts as "arrived" (meters)

# Assign your waypoints here (drag Node3D nodes into the array in the editor)
@export var waypoints: Array[Node3D] = []

# Optional: face the movement direction
@export var align_to_path: bool = false

var _current_index: int = 0
var _stopped: bool = false

func _ready() -> void:
	if waypoints.is_empty():
		push_warning("PathFollower3D: 'waypoints' is empty.")
		_stopped = true
		return
	# Optionally snap to the first point and start heading to the next one
	if snap_to_first_point:
		global_position = waypoints[0].global_position
		_current_index = min(1, waypoints.size() - 1)
	else:
		_current_index = 0
		
		
func _physics_process(delta: float) -> void:
	if _stopped:
		return 
		
	var target_position: Vector3 = waypoints[_current_index].global_position
	var direction: Vector3 = target_position - global_position
	var dist: float = direction.length()
	
	if dist <= arrive_radius:
		_advance_or_finish()
		print("PathFollower3D: _advance_or_finish")
		if _stopped:
			return
	
	# Constant speed: clamp so we don't overshoot this frame
	#var dir: Vector3 = to_target / dist
	#velocity = direction.normalized() * speed
	global_position = global_position.move_toward(target_position, speed * delta)
	print("PathFollower3D: current index :" , _current_index, "position:" ,global_position , "dist = " , dist)
	#move_and_slide()
	
	
func _advance_or_finish() -> void:
	# If we were heading to the final point
	if _current_index >= waypoints.size() - 1:
		if loop and waypoints.size() >= 2:
			_current_index = 0  # wrap back to start
		else:
			#velocity = Vector3.ZERO
			_stopped = true
			#emit_signal("path_finished")
	else:
		_current_index += 1	
		
