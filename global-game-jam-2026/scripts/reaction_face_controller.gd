class_name ReactionFaceController extends Node

var happy_handle:TextureRect
var angry_handle:TextureRect

var happy_eyes_handle:TextureRect
var angry_eyes_handle:TextureRect

var is_popup_active:bool = false
var initial_position:Vector2
var anim_time:float = 0.35

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	happy_handle = get_node("face_happy")
	angry_handle = get_node("face_bad")
	happy_eyes_handle = get_node("eyes/eyes_happy")
	angry_eyes_handle = get_node("eyes/eyes_bad")
	
	initial_position = self.global_position
	
	self.rotation = 0.0
	self.get_node("eyes").rotation = 0.0
	
	Global.popup_happy.connect(on_popup.bind("happy"))
	Global.popup_angry.connect(on_popup.bind("angry"))
	hide_popup()
	
func popup_face(pos:Vector2):
	is_popup_active = true
	get_node("reaction_particles").emitting = true
	self.global_position = initial_position
	self.global_position.y += 150.0
	
	self.modulate.a = 0.0
	
	SimonTween.start_tween(self,"modulate:a",1.0,anim_time)
	SimonTween.start_tween(self,"global_position:y",-150.0,anim_time*2.0,Global.anim_curves_B.curve_x).set_relative(true)
	await get_tree().create_timer(anim_time * 0.25).timeout
	SimonTween.start_tween(get_node("eyes"),"rotation",deg_to_rad(8),anim_time*0.40,Global.anim_curves_B.curve_y).set_loops(40).set_relative(true)
	SimonTween.start_tween(self,"rotation",deg_to_rad(3),anim_time*0.45,Global.anim_curves_B.curve_y).set_loops(40).set_start_snap(true).set_relative(true)
	
	SimonTween.start_tween(self,"scale",Vector2.ONE * 1.4,anim_time,Global.anim_curves_A.curve_x)
	await get_tree().create_timer(1.0).timeout
	hide_popup()
	
func popup_happy(pos:Vector2):
	popup_face(pos)
	angry_handle.visible = false
	happy_handle.visible = true
	angry_eyes_handle.visible = false
	happy_eyes_handle.visible = true
	
func popup_angry(pos:Vector2):
	popup_face(pos)
	angry_handle.visible = true
	happy_handle.visible = false
	angry_eyes_handle.visible = true
	happy_eyes_handle.visible = false
	
func hide_popup():
	get_node("reaction_particles").emitting = false
	SimonTween.start_tween(self,"global_position:y",150.0,anim_time).set_relative(true)
	await get_tree().create_timer(anim_time * 0.25).timeout
	await SimonTween.start_tween(self,"modulate:a",0.0,anim_time*0.5).set_end_snap(true).tween_finished
	is_popup_active = false
	self.global_position = initial_position
	
func on_popup(pos:Vector2,id:String):
	match id:
		"happy":
			popup_happy(pos)
		"angry":
			popup_angry(pos)
