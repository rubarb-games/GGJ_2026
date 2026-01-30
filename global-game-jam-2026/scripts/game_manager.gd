extends Node

var start_game_handle:Control
var gameplay_handle:Control
var end_game_handle:Control

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
	
	
func on_pre_scene_started():
	setup()
	
func setup():
	get_refs()
	
	start_game_handle.visible = false
	gameplay_handle.visible = false
	end_game_handle.visible = false
	
	start_game_handle.get_node("start_game_button").pressed.connect(on_start_button_pressed)
	end_game_handle.get_node("end_game_button").pressed.connect(on_restart_button_pressed)
	gameplay_handle.get_node("gameplay_skip_button").pressed.connect(on_gameplay_skip_pressed)
	
	Global.on_start.emit()
	
func on_start():
	start_game_handle.visible = true

func on_gameplay_started():
	start_game_handle.visible = false
	gameplay_handle.visible = true
	
func on_finish():
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
