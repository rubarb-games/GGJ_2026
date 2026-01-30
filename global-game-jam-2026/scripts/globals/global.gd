extends Node

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

signal viewport_texture_ready(viewport_texture:ViewportTextureController, mirror_node_parent:Control)
