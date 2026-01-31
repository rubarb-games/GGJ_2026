class_name ShapeButtonController extends Node

var shape:Global.GameplayShapes

var circle_scene:PackedScene = preload("res://prefabs/pf_shape_circle.tscn")
var rect_scene:PackedScene = preload("res://prefabs/pf_shape_rect.tscn")
var line_scene:PackedScene = preload("res://prefabs/pf_shape_line.tscn")

var current_scene:PackedScene

func setup():
	get_node("Button").button_down.connect(on_button_down)

func on_button_down():
	if GameManager.is_placing():
		instance_scene()
	
func instance_scene():
	var active_shape:ShapeController = current_scene.instantiate()
	
	GameManager.shape_parent.add_child(active_shape)
	active_shape.global_position = get_viewport().get_mouse_position()
	active_shape.setup()
	active_shape.set_mirror_parent(ImageManager.mirror_parent)

	Global.shape_spawned.emit()

func set_gameplay_shape(p_shape:Global.GameplayShapes):
	shape = p_shape
	
	match shape:
		Global.GameplayShapes.CIRCLE:
			current_scene = circle_scene
		Global.GameplayShapes.RECT:
			current_scene = rect_scene
		Global.GameplayShapes.LINE:
			current_scene = line_scene
