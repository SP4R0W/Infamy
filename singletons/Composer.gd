extends Node

onready var current_scene: Node2D = null

onready var screen: Vector2 = OS.get_window_size()

var is_entering_scene: bool = false

func goto_scene(new_scene: String, animated: bool, sound_on: bool, fade_in_duration: float, fade_out_duration: float) -> void:
	#don't try to enter a new scene if you're already in a process of transitioning to another.
	if (is_entering_scene):
		return
		
	#play sound (i.e button click)
	if (sound_on):
		pass
		
	#make sure to claim our process so no one interrupts it
	is_entering_scene = true
	call_deferred("deffered_goto_scene",new_scene,animated,fade_in_duration,fade_out_duration)
	
func deffered_goto_scene(new_scene: String, animated: bool, fade_in_duration: float, fade_out_duration: float) -> void:
	#get root for easy typing
	var root = Global.root
	
	if (animated):
		#get the components require for animation
		var transitionRect: ColorRect = root.get_node("Control/CanvasLayer/TransitionRect")
		var tween: Tween = root.get_node("Tween")
		
		transitionRect.visible = true
		
		#check if a previous scene has existed or not
		if (current_scene != null):
			transitionRect.set_frame_color(Color(0,0,0,0))
			
			tween.interpolate_property(transitionRect,"color",Color(0,0,0,0),Color.black,fade_in_duration,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
			tween.start()
			
			yield(tween, "tween_all_completed")
		
			#remove the old scene
			var scene = root.get_node(current_scene.name)
			scene.queue_free()
			
		else:
			transitionRect.set_frame_color(Color.black)
			
		#load the new scene and add it to root
		var next_scene = load(new_scene)
		root.add_child(next_scene.instance())
		
		tween.interpolate_property(transitionRect, "color",Color.black, Color(0, 0, 0, 0), fade_out_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		
		yield(tween, "tween_all_completed")

		transitionRect.visible = false
		
		# get the current_scene
		current_scene = root.get_child(root.get_child_count() - 1)	
	else:
		if (current_scene != null):
			#remove the old scene
			var scene = root.get_node(current_scene.name)
			scene.queue_free()
			
		#load the new scene and add it to root
		var next_scene = load(new_scene)
		root.add_child(next_scene.instance())
			
		current_scene = root.get_child(root.get_child_count() - 1)
		
	#process done
	is_entering_scene = false
