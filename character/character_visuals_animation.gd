extends Node
class_name CharacterVisualsAnimation

@export var anim: AnimationPlayer

const IDLE_ANIM := "character_animations/Idle"   # Use your exact clip names
const RUN_ANIM  := "character_animations/Run"




func _ready() -> void:
	anim.play(IDLE_ANIM)  # start idle by default

	
	
func _physics_process(_dt: float) -> void:
	var move_axis := Input.get_vector("CharLeft", "CharRight", "CharForward", "CharBackward")
	var is_pressing_move := move_axis.length_squared() > 0.0
	if is_pressing_move:
		if anim.current_animation != RUN_ANIM:
			anim.play(RUN_ANIM)   # loops automatically if the clip is set to loop
	else:
		if anim.current_animation != IDLE_ANIM:
			anim.play(IDLE_ANIM)	
	

func pp_animations():
	for name in anim.get_animation_list():
		print(name)	
		
