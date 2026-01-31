class_name ShapeController extends Node

enum ShapeMode  { IDLE, PLACING, SCALING, GIRTH, PLACED }
var shapeMode:ShapeMode = ShapeMode.PLACING

@export var control_type:Global.ShapeControlType

var is_main_action_down:bool = false
var is_secondary_action_down:bool = false

var mirror_object:TextureRect

var is_over_document:bool = false

var mouse_held_down:bool = false

var active:bool = false
var mouse_offset:Vector2
var mouse_offset_secondary:Vector2
var mouse_offset_tertiary:Vector2

var initial_position_secondary:Vector2
var initial_position_tertiary:Vector2

var initial_size_secondary:Vector2
var initial_size_tertiary:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup():
	set_mouse_offset()
	
	mirror_object = TextureRect.new()#self.get_child(0).duplicate()
	self.add_child(mirror_object)
	mirror_object.texture = self.get_child(0).texture
	mirror_object.modulate = self.get_child(0).modulate
	mirror_object.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	
	ImageManager.display_texture.mouse_entered.connect(on_mouse_entered_texture.bind(true))
	ImageManager.display_texture.mouse_exited.connect(on_mouse_entered_texture.bind(false))
	
	Global.timer_end.connect(on_timer_end)
	
	#advance_state()
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	active = true
	
	return true
	
func set_mirror_parent(parent:Node):
	mirror_object.reparent(parent)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
		
	var offset:Vector2 = get_viewport().get_mouse_position() - self.global_position
		
	match shapeMode:
		#SHAPEMODE
		ShapeMode.PLACING:
			self.global_position = get_viewport().get_mouse_position() - mouse_offset
		#SCALING
		ShapeMode.SCALING:
			match control_type:
				Global.ShapeControlType.SCALE:
					var initial_pos_offset = get_viewport().get_mouse_position() - initial_position_secondary
					#var initial_mouse_pos_offset = get_viewport().get_mouse_position()
					if offset.x < 0:
						self.position.x = initial_position_secondary.x + initial_pos_offset.x
						self.size.x = abs(initial_pos_offset.x)
					if offset.x > 0:
						self.position.x = initial_position_secondary.x
						self.size.x = offset.x
					if offset.y < 0:
						self.position.y = initial_position_secondary.y + initial_pos_offset.y
						self.size.y = abs(initial_pos_offset.y)
					if offset.y > 0:
						self.position.y = initial_position_secondary.y
						self.size.y = offset.y
					#self.size = offset
				Global.ShapeControlType.STRETCH:
					self.size.x = offset.length()
					self.rotation = Vector2.RIGHT.angle_to((offset + (Vector2.ONE * self.size.y * 0.5)).normalized())
					#print(initial_position_secondary + (Vector2.UP.rotated(self.rotation) * 50.0))
					#await get_tree().process_frame
					self.position = initial_position_secondary + (Vector2.UP.rotated(self.rotation) * (self.size.y*0.5))
		#GIRTH
		ShapeMode.GIRTH:
			match control_type:
				Global.ShapeControlType.SCALE:
					advance_state()
				Global.ShapeControlType.STRETCH:
					var mag:float = Vector2(get_viewport().get_mouse_position() - mouse_offset_tertiary).length() / 2.0
					self.size.y = mag + initial_size_tertiary.y
					self.global_position = initial_position_tertiary
					#self.global_position += (Vector2.UP.rotated(self.rotation) * (self.size.y * 0.5))
					self.global_position +=  (Vector2.UP.rotated(self.rotation) * (mag/2.0))
		#ShapeMode.PLACED:
			#return
		
	if Input.is_action_just_pressed("main_action") and (shapeMode == ShapeMode.PLACING or shapeMode == ShapeMode.GIRTH):
		if !GameManager.is_over_document:
			on_deactivate(true)
		advance_state()
		
	if Input.is_action_just_released("main_action") and (shapeMode == ShapeMode.SCALING):
		advance_state()
		
	update_mirror_object()
		
	return
	
	#if Input.is_action_just_released("main_action"):
		#on_main_action_up()
		#
	#if Input.is_action_just_pressed("secondary_action"):
		#on_secondary_action_down()
		#
	#if Input.is_action_just_released("secondary_action"):
		#on_secondary_action_up()
		#
	#if is_secondary_action_down:
		#do_secondary_motion()
	#else:
		#self.global_position = get_viewport().get_mouse_position() - mouse_offset
		
func update_mirror_object():
	mirror_object.global_position = self.global_position
	mirror_object.size = self.size
	mirror_object.rotation = self.rotation
		
func do_secondary_motion():
	var offset:Vector2 = get_viewport().get_mouse_position() - self.global_position

func advance_state():
	match shapeMode:
		ShapeMode.IDLE:
			shapeMode = ShapeMode.PLACING
		ShapeMode.PLACING:
			shapeMode = ShapeMode.SCALING
			mouse_offset_secondary = get_viewport().get_mouse_position()
			initial_position_secondary = self.global_position
			initial_size_secondary = self.size
		ShapeMode.SCALING:
			shapeMode = ShapeMode.GIRTH
			mouse_offset_tertiary = get_viewport().get_mouse_position()# - self.global_position
			initial_position_tertiary = self.global_position
			initial_size_tertiary = self.size
		ShapeMode.GIRTH:
			shapeMode = ShapeMode.PLACED
			on_deactivate()
			
	SimonTween.start_tween(self.get_child(0),"position:y",-15.0,0.15,Global.anim_curves_A.curve_y)

func die():
	nuke()
	
func nuke():
	self.queue_free()

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

func on_deactivate(disable_signal:bool = false):
	active = false
	if GameManager.is_over_document:
		GameManager.set_active_shape(null)
		if !disable_signal:
			Global.shape_placed.emit()
	else:
		die()

func on_mouse_entered_texture(action:bool):
	if action:
		if Input.is_action_pressed("main_action"):
			mouse_held_down = true
		else:
			mouse_held_down = false
		is_over_document = true
	else:
		is_over_document = false

func on_timer_end():
	shapeMode = ShapeMode.PLACED
	on_deactivate(true)
