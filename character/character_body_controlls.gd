extends CharacterBody3D
class_name CharacterBodyControlls


@export var visuals: Node3D              # The mesh/visuals Node3D (child of body)
@export var cam: Node3D                  # The camera (or its pivot) Node3D

@export var move_speed: float = 8.0      # m/s
@export var turn_speed: float = 7.0     # how quickly we rotate toward input
@export var align_dot: float = 0.7       # how aligned before we start moving (0..1)
@export var gravity: float = 50.      # how aligned before we start moving (0..1)
@export var max_fall_speed: float = 20.      # how aligned before we start moving (0..1)
@export var jump_speed: float = 20.      # how aligned before we start moving (0..1)
#@export var damping: float = 20.0        # how fast we stop when no input / unaligned
var touching := {} # RID -> true
var is_jump_enabled  = false
func _ready() -> void:
	assert(visuals, "CharacterBodyControlls : visuals not set" ) 
	assert(cam, "CharacterBodyControlls : camera  not set" ) 

	
	
func _physics_process(delta: float) -> void:
	var move_axis := Input.get_vector("CharLeft", "CharRight", "CharForward", "CharBackward")
	var old_vel_y := velocity.y
	if move_axis.length() > 0.0001:
		var desired_dir := _desired_direction(move_axis, cam)
		var new_forward := _rotate_visuals_toward(visuals,desired_dir,turn_speed,delta)
		var is_aligned := _is_aligned(new_forward,desired_dir,align_dot)
		if is_aligned:
			velocity = -new_forward*move_speed 
	else:
		velocity = Vector3(0, 0, 0)
	#apply gravity:
	 #old_vel_y - gravity * delta
		
	#var is_jump_enabled = is_jump_enabled_for_collision_objects(touching.keys())
	is_jump_enabled = is_on_floor()
	if  is_jump_enabled:
		if Input.is_action_just_pressed("CharJump"):
			old_vel_y = jump_speed
	else:
		old_vel_y -=gravity * delta
		old_vel_y = clampf(old_vel_y, - max_fall_speed, max_fall_speed)
		#old_vel_y += old_vel_y
	velocity.y = old_vel_y	
		
	print("is_jump_enabled : " , is_jump_enabled)
	#print("velocity.y : " , velocity.y)
	move_and_slide()
	
func _unhandled_input(_event: InputEvent) -> void:
	if is_jump_enabled:
		if Input.is_action_just_pressed("CharJump"):
			velocity.y = jump_speed
			print("CharJump : " , velocity.y)

		
			

func _on_body_entered(body: Node) -> void:
	if body is CollisionObject3D:
		touching[(body as CollisionObject3D).get_rid()] = true
		
func _on_body_exited(body: Node) -> void:
	if body is CollisionObject3D:
		touching.erase((body as CollisionObject3D).get_rid())		
		

func is_jump_enabled_for_collision_objects(objs :Array, max_surface_tilt_deg: float = 10.0) -> bool:
	var space := get_world_3d().direct_space_state
	return false
	
	
	


static func _desired_direction(axis: Vector2 , cam: Node3D ) -> Vector3:
	var b := cam.global_transform.basis
	var fwd := b.z
	var right := b.x
	fwd.y = 0.0
	right.y = 0.0
	fwd = fwd.normalized()
	right = right.normalized()
	
	var dir := right * axis.x + fwd * axis.y
	return dir.normalized()
	
	
static func _rotate_visuals_toward(visuals: Node3D , target_dir: Vector3, turn_speed : float, delta: float) -> Vector3:
	var old_forward := -visuals.global_transform.basis.z
	old_forward.y = 0.0
	old_forward = old_forward.normalized()
	var t :float= clamp(turn_speed * delta, 0.0, 1.0)
	var new_forward := old_forward.slerp(target_dir, t).normalized()
	var p := visuals.global_transform.origin
	visuals.look_at(p + new_forward, Vector3.UP) # keeps pitch at 0
	return new_forward
	
static func _is_aligned(a: Vector3, b: Vector3, align_dot: float) -> bool:
	return a.dot(b) >= align_dot


# Static helper: returns true if any contact normal is within `max_surface_tilt_deg`
# of UP (i.e., surface is flat enough to allow a jump).
static func _is_jump_enabled_for_slide_collisions(capsule_body: CharacterBody3D, max_surface_tilt_deg: float = 10.0) -> bool:
	var up := Vector3.UP
	var dot_limit := cos(deg_to_rad(max_surface_tilt_deg)) # n·UP >= dot_limit ⇒ angle ≤ max_surface_tilt_deg
	var hits := capsule_body.get_slide_collision_count()
	for i in hits:
		var col := capsule_body.get_slide_collision(i)
		if col:
			var n := col.get_normal().normalized()
			if n.dot(up) >= dot_limit:
				return true
	return false
