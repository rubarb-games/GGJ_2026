extends Node

enum State { START_MENU, GAMEPLAY_PLACING, GAMEPLAY_SCORING, GAMEPLAY_TRANSITION, END_SCREEN }
var state:State = State.START_MENU

var start_game_handle:Control
var gameplay_handle:Control
var end_game_handle:Control

var button_A:ShapeButtonController
var button_B:ShapeButtonController
var button_C:ShapeButtonController

var shape_parent:Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_scene_started.connect(on_pre_scene_started)
	
	Global.on_start.connect(on_start)
	Global.on_gameplay_started.connect(on_gameplay_started)
	Global.on_finish.connect(on_finish)
	Global.on_restart.connect(on_restart)
	
	
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

func is_menu():
	return true if state == State.START_MENU or state == State.END_SCREEN else false
	
func is_placing():
	return true if state == State.GAMEPLAY_PLACING else false
	
func is_scoring():
	return true if state == State.GAMEPLAY_SCORING else false
