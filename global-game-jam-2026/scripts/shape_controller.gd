class_name ShapeController extends Node

@export var control_type:Global.ShapeControlType

var is_main_action_down:bool = false
var is_secondary_action_down:bool = false

var mirror_object:TextureRect

var active:bool = false
var mouse_offset:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup():
	active = true
	set_mouse_offset()
	
	mirror_object = TextureRect.new()#self.get_child(0).duplicate()
	self.add_child(mirror_object)
	mirror_object.texture = self.get_child(0).texture
	mirror_object.modulate = self.get_child(0).modulate
	mirror_object.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
func set_mirror_parent(parent:Node):
	mirror_object.reparent(parent)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
		
	if Input.is_action_just_released("main_action"):
		on_main_action_up()
		
	if Input.is_action_just_pressed("secondary_action"):
		on_secondary_action_down()
		
	if Input.is_action_just_released("secondary_action"):
		on_secondary_action_up()
		
	if is_secondary_action_down:
		do_secondary_motion()
	else:
		self.global_position = get_viewport().get_mouse_position() - mouse_offset
		
	mirror_object.global_position = self.global_position
	mirror_object.size = self.size
	mirror_object.rotation = self.rotation
	
		
func do_secondary_motion():
	var offset:Vector2 = get_viewport().get_mouse_position() - self.global_position
	
	match control_type:
		Global.ShapeControlType.SCALE:
			self.size = offset
		Global.ShapeControlType.STRETCH:
			self.size.x = offset.length()
			self.rotation = Vector2.RIGHT.angle_to(offset.normalized())

func on_secondary_action_down():
	is_secondary_action_down = true
	
func on_secondary_action_up():
	set_mouse_offset()
	is_secondary_action_down = false
	
func on_main_action_up():
	on_deactivate()
	is_main_action_down = false

func set_mouse_offset():
	mouse_offset = get_viewport().get_mouse_position() - self.global_position

func on_deactivate():
	active = false
	Global.shape_placed.emit()
