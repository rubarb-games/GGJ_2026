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
		GameManager.set_shape(shape)
		GameManager.instance_scene()

func set_gameplay_shape(p_shape:Global.GameplayShapes):
	shape = p_shape
	
	match shape:
		Global.GameplayShapes.CIRCLE:
			current_scene = circle_scene
		Global.GameplayShapes.RECT:
			current_scene = rect_scene
		Global.GameplayShapes.LINE:
			current_scene = line_scene
