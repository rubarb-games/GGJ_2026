extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.pre_scene_started.emit()
	await get_tree().process_frame
	Global.scene_started.emit()
	await get_tree().process_frame
	Global.post_scene_started.emit()
