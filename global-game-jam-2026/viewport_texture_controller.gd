class_name ViewportTextureController extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.viewport_texture_ready.emit(self, get_parent().get_parent().get_child(1))
