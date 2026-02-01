extends Node

var music:AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_scene_started.connect(on_pre_scene_started)
	
func on_pre_scene_started():
	$music.play()
