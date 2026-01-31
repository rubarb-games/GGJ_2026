extends Node

var anim_curves_A:CurveXYZTexture = load("res://art/misc/anim_curves_A.tres")

enum ShapeControlType { SCALE, STRETCH }
enum GameplayShapes { CIRCLE, RECT, LINE }

signal pre_scene_started()
signal scene_started()
signal post_scene_started()

signal on_start()
signal on_gameplay_started()
signal on_finish()
signal on_end()
signal on_restart()

signal timer_start()
signal timer_end()

signal viewport_texture_ready(viewport_texture:ViewportTextureController, mirror_node_parent:Control)
signal shape_spawned()
signal shape_placed()

signal do_fireworks(position:Vector2)
