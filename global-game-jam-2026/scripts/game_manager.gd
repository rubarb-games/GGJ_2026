extends Node

enum State { START_MENU, GAMEPLAY_PLACING, GAMEPLAY_SCORING, GAMEPLAY_TRANSITION, END_SCREEN }
var state:State = State.START_MENU

var start_game_handle:Control
var gameplay_handle:Control
var end_game_handle:Control

var button_A:ShapeButtonController
var button_B:ShapeButtonController
var button_C:ShapeButtonController

var circle_scene:PackedScene = preload("res://prefabs/pf_shape_circle.tscn")
var rect_scene:PackedScene = preload("res://prefabs/pf_shape_rect.tscn")
var line_scene:PackedScene = preload("res://prefabs/pf_shape_triangle.tscn")
var current_scene:PackedScene
var shape:Global.GameplayShapes

var is_over_document:bool = false
var mouse_held_down:bool = false

var shape_parent:Control

var current_active_shape:ShapeController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_scene_started.connect(on_pre_scene_started)
	
	Global.on_start.connect(on_start)
	Global.on_gameplay_started.connect(on_gameplay_started)
	Global.on_finish.connect(on_finish)
	Global.on_restart.connect(on_restart)
	
	get_node("/root/main/backing/texture_image").mouse_entered.connect(on_mouse_entered_texture.bind(true))
	get_node("/root/main/backing/texture_image").mouse_exited.connect(on_mouse_entered_texture.bind(false))	
	
func get_refs():
	start_game_handle = get_node("/root/main/ui/ui_start_menu")
	gameplay_handle = get_node("/root/main/ui/ui_gameplay")
	end_game_handle = get_node("/root/main/ui/ui_end_menu")
	
	shape_parent = get_node("/root/main/shape_parent")
	
	button_A = get_node("/root/main/shape_button_A")
	button_B = get_node("/root/main/shape_button_B")
	button_C = get_node("/root/main/shape_button_C")
	
	
func on_pre_scene_started():
	setup()
	#setup()
	ImageManager.setup()
	
func setup():
	get_refs()
	
	start_game_handle.visible = false
	gameplay_handle.visible = false
	end_game_handle.visible = false
	
	start_game_handle.get_node("start_game_button").pressed.connect(on_start_button_pressed)
	end_game_handle.get_node("end_game_button").pressed.connect(on_restart_button_pressed)
	gameplay_handle.get_node("gameplay_skip_button").pressed.connect(on_gameplay_skip_pressed)
	
	button_A.set_gameplay_shape(Global.GameplayShapes.CIRCLE)
	button_A.setup()

	button_B.set_gameplay_shape(Global.GameplayShapes.RECT)
	button_B.setup()
	
	button_C.set_gameplay_shape(Global.GameplayShapes.LINE)
	button_C.setup()	
	
	Global.on_start.emit()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("main_action"):
		await get_tree().process_frame
		if !current_active_shape and current_scene and state == State.GAMEPLAY_PLACING:
			instance_scene(true)
	
func set_shape(p_shape:Global.GameplayShapes):
	match p_shape:
		Global.GameplayShapes.CIRCLE:
			current_scene = circle_scene
		Global.GameplayShapes.RECT:
			current_scene = rect_scene
		Global.GameplayShapes.LINE:
			current_scene = line_scene
	
func instance_scene(spawn_last:bool = false):
	var active_shape:ShapeController = current_scene.instantiate()
	
	GameManager.shape_parent.add_child(active_shape)
	active_shape.z_index = 0
	active_shape.global_position = get_viewport().get_mouse_position()
	Global.shape_spawned.emit()
	set_active_shape(active_shape)
	await active_shape.setup()
	active_shape.set_mirror_parent(ImageManager.mirror_parent)
	
	#set_active_shape(active_shape)
	if spawn_last:
		active_shape.advance_state()
	
func gameplay_placing_end():
	set_gameplay_scoring()
	
func on_start():
	set_start_menu()
	start_game_handle.visible = true
	await get_tree().create_timer(1.0).timeout
	#ImageManager.setup()

func on_gameplay_started():
	set_gameplay_placing()
	start_game_handle.visible = false
	gameplay_handle.visible = true
	
func on_finish():
	set_end_menu()
	gameplay_handle.visible = false
	end_game_handle.visible = true
	
	var number_spacing:float = 45.0
	
	var total_score_handle:Control = get_node("/root/main/ui/ui_end_menu/total_score")
	var label_handle = total_score_handle.get_child(0)
	total_score_handle.visible = true
	var first_entry = ImageManager.total_score.pop_front()
	label_handle.text = str(first_entry)
	var total_sum = first_entry
	for entry:int in ImageManager.total_score:
		#var new_label:Label = Label.new()
		var new_label = label_handle.duplicate()
		total_score_handle.add_child(new_label)
		#new_label.position.y = total_score_handle.get_child_count() * 30.0
		#total_score_handle.add_child(new_label)
		#new_label.theme = label_handle.theme
		new_label.modulate.a = 0.0
		new_label.text = str(entry)
		SimonTween.start_tween(new_label,"modulate:a",1.0,0.5).set_relative(true)
		await SimonTween.start_tween(new_label,"position:y",number_spacing,0.5).set_relative(true).tween_finished
		label_handle = new_label
		total_sum += entry

	var sum_line:ColorRect = get_node("/root/main/ui/ui_end_menu/sum_line")
	sum_line.visible = true
	sum_line.global_position = label_handle.global_position + Vector2(0.0,number_spacing - 2.5)

	var last_label:Label = label_handle.duplicate()
	total_score_handle.add_child(last_label)
	#last_label.position.y = total_score_handle.get_child_count() * 30.0
	await get_tree().create_timer(0.5).timeout
	last_label.modulate.a = 0.0
	last_label.text = str(total_sum)
	
	last_label.modulate.a = 0.0
	last_label.text = str(total_sum)
	SimonTween.start_tween(last_label,"modulate:a",1.0,0.5).set_relative(true)
	await SimonTween.start_tween(last_label,"position:y",number_spacing,0.5).set_relative(true).tween_finished
		
		
	
	
func on_restart():
	get_tree().reload_current_scene()

func on_start_button_pressed():
	Global.on_gameplay_started.emit()

func on_restart_button_pressed():
	Global.on_restart.emit()

func on_gameplay_skip_pressed():
	Global.on_finish.emit()

func set_start_menu():
	state = State.START_MENU
	
func set_end_menu():
	state = State.END_SCREEN
	
func set_gameplay_placing():
	state = State.GAMEPLAY_PLACING
	
func set_gameplay_scoring():
	state = State.GAMEPLAY_SCORING

func set_active_shape(shape:ShapeController):
	current_active_shape = shape

func is_menu():
	return true if state == State.START_MENU or state == State.END_SCREEN else false
	
func is_placing():
	return true if state == State.GAMEPLAY_PLACING else false
	
func is_scoring():
	return true if state == State.GAMEPLAY_SCORING else false

func on_mouse_entered_texture(action:bool):
	if action:
		if Input.is_action_pressed("main_action"):
			mouse_held_down = true
		else:
			mouse_held_down = false
		is_over_document = true
	else:
		is_over_document = false
