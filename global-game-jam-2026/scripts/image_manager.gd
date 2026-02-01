extends Node

var display_texture:TextureRect
var viewport_texture:TextureRect
var reference_texture:TextureRect
var current_texture:Texture

var timer_handle:Control

var scoring_handle:Control

var status_text_handle:Control

var ui_gameplay_handle:Control

var top_level_texture:TextureRect

var scoring_bar:ColorRect

var all_image_paths:Array[String]
var all_images:Array[Texture]
var image_size:int = 64
var mirror_parent:Control

var shapes_placed:int = 0
var max_shapes_placed:int = 8

var current_time:float = 0.0
var clamped_time:int  = 0
var max_time:float = 14.0
var timer_active:bool = false

var default_pixels:AmericanPixels
var pixels:AmericanPixels

var encounter_no:int = 0
var max_encounters:int = 5

var red_score:int = 0
var white_score:int = 0
var blue_score:int = 0
var white_score_B:int = 0

var total_score:Array[int]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.viewport_texture_ready.connect(on_texture_ready)
	Global.post_scene_started.connect(on_post_game_started)
	Global.shape_placed.connect(on_shape_placed)
	Global.on_gameplay_started.connect(on_gameplay_started)
	Global.timer_end.connect(on_timer_end)

func on_post_game_started():
	pass
	#setup()

func get_refs():
	display_texture = get_node("/root/main/backing/texture_image") 
	reference_texture = get_node("/root/main/backing/TextureRect")
	
	status_text_handle = get_node("/root/main/ui/ui_gameplay/status_text_parent")
	scoring_handle = get_node("/root/main/ui/ui_gameplay/scoring")
	timer_handle = get_node("/root/main/ui/ui_gameplay/timer")
	
	ui_gameplay_handle = get_node("/root/main/ui/ui_gameplay")
	
	top_level_texture = get_node("/root/main/backing2/texture_overlay")
	scoring_bar = get_node("/root/main/ui/ui_gameplay/scoring/scoring_bar")
	
func setup():
	get_refs()
	#get_resources_from_folder("res://art/textures/artworks/",all_image_paths)
	get_resources_from_resource()
	#all_images = []
	total_score = []
	encounter_no = 0
	
	for p in all_image_paths:
		var tex = load(p)
		if tex:
			all_images.append(tex)
	
	all_images.shuffle()
	
func start_gameplay():
	
	encounter_no += 1
	#var new_image_path = #all_images.pop_front()
	if all_images.size() < 1 or encounter_no > max_encounters:
		print("YOU WON!")
		Global.on_finish.emit()
		return 
	
	GameManager.open_barn_doors()
	
	get_node("/root/main/ui/ui_gameplay/encounter_label").text = "%d / %d" % [encounter_no, max_encounters] 
	
	shapes_placed = 0
	update_shapes_place_label()
	
	start_timer()
	
	scoring_handle.visible = false
	timer_handle.visible = true
	
	popup_status_text("Start!")
	default_pixels = AmericanPixels.new()
	pixels = AmericanPixels.new()
	new_image()
	
	var signature_text = current_texture.resource_path.split("__")
	get_node("/root/main/ui/ui_gameplay/artwork_label").text = "\"%s\"" % signature_text.get(1)
	get_node("/root/main/ui/ui_gameplay/signature_label").text = "By %s" % signature_text.get(2)
	
	timer_handle.modulate.a = 0.0
	await get_tree().create_timer(1.0).timeout
	SimonTween.start_tween(timer_handle,"modulate:a",1.0,0.5)

func stop_gameplay():
	calculate_score()
	
	scoring_handle.visible = true
	timer_handle.visible = false
	
	var positive_label:Label = scoring_handle.get_node("positive_points_label")
	var negative_label:Label = scoring_handle.get_node("negative_points_label")
	var negative_B_label:Label = scoring_handle.get_node("negative_points_B_label")
	var total_label:Label = scoring_handle.get_node("total_label")
	
	positive_label.text = ""
	negative_label.text = ""
	negative_B_label.text = ""
	total_label.text = ""
	
	#var b_l = ui_gameplay_handle.get_node("barn_doors_left")
	#var b_r = ui_gameplay_handle.get_node("barn_doors_right")
	
	var scoring_bar_size:float = scoring_bar.size.x
	scoring_bar.size.x = 0.0

	SimonTween.start_tween_callable(0.0,0.75,lerp_shader_value.bind("only_orig_image"),0.25)
	
	await get_tree().create_timer(1.0).timeout

	SimonTween.start_tween_callable(0.0,1.0,lerp_shader_value.bind("only_interior_lines"),0.25)
	
	positive_label.modulate.a = 0.0
	positive_label.text = str(blue_score)
	SimonTween.start_tween(positive_label,"position:y",-10.0,0.3,Global.anim_curves_A.curve_y).set_relative(true)
	await SimonTween.start_tween(positive_label,"modulate:a",1.0,0.3).tween_finished
	await get_tree().create_timer(0.35).timeout

	SimonTween.start_tween_callable(1.0,0.0,lerp_shader_value.bind("only_interior_lines"),0.25)
	SimonTween.start_tween_callable(0.0,1.0,lerp_shader_value.bind("only_ext_lines"),0.25)
	
	negative_label.modulate.a = 0.0
	negative_label.text = "-"+str(white_score)
	SimonTween.start_tween(negative_label,"position:y",-10.0,0.3,Global.anim_curves_A.curve_y).set_relative(true)
	await SimonTween.start_tween(negative_label,"modulate:a",1.0,0.3).tween_finished
	await get_tree().create_timer(0.35).timeout

	SimonTween.start_tween_callable(1.0,0.0,lerp_shader_value.bind("only_ext_lines"),0.25)
	SimonTween.start_tween_callable(0.75,0.0,lerp_shader_value.bind("only_orig_image"),0.25)
	SimonTween.start_tween_callable(0.0,1.0,lerp_shader_value.bind("only_non_filled_lines"),0.25)
		
	negative_B_label.modulate.a = 0.0
	negative_B_label.text = str("-"+str(white_score_B))
	SimonTween.start_tween(negative_B_label,"position:y",-10.0,0.3,Global.anim_curves_A.curve_y).set_relative(true)
	await SimonTween.start_tween(negative_B_label,"modulate:a",1.0,0.3).tween_finished
	await get_tree().create_timer(0.5).timeout
	
	SimonTween.start_tween(scoring_bar,"size:x",scoring_bar_size,0.25)
	
	await get_tree().create_timer(0.5).timeout
	total_label.modulate.a = 0.0
	total_label.text = str(blue_score - white_score_B - white_score)+"!!!"
	SimonTween.start_tween(total_label,"position:y",-10.0,0.3,Global.anim_curves_A.curve_y).set_relative(true)
	
	Global.do_fireworks.emit(total_label.global_position + (total_label.size/2.0))
	await SimonTween.start_tween(total_label,"modulate:a",1.0,0.3).tween_finished
	await get_tree().create_timer(0.15).timeout
	
	var final_score = blue_score - white_score_B - white_score
	total_score.append(final_score)
	
	await get_tree().create_timer(0.25).timeout
	if final_score > 0:
		popup_status_text("Certified \n OK!",1.0)
		Global.popup_happy.emit(Vector2.ZERO)
	else:
		popup_status_text("Wow, it bad??",1.0)
		Global.popup_angry.emit(Vector2.ZERO)
	await get_tree().create_timer(0.75).timeout
	
	GameManager.close_barn_doors()
	#b_l.position.x = -300.0
	#b_r.position.x = 940.0
	#SimonTween.start_tween(b_l,"position:x",b_l.size.x,0.5).set_relative(true)
	#SimonTween.start_tween(b_r,"position:x",-b_r.size.x,0.5).set_relative(true)
	
	await get_tree().create_timer(0.4).timeout
	top_level_texture.material.set_shader_parameter("only_non_filled_lines",0.0)
	top_level_texture.material.set_shader_parameter("only_orig_image",0.0)
	top_level_texture.material.set_shader_parameter("only_interior_lines",0.0)
	top_level_texture.material.set_shader_parameter("only_ext_lines",0.0)

	Global.on_gameplay_started.emit()

func lerp_shader_value(value:float, property:String): 
	top_level_texture.material.set_shader_parameter(property,value)

func _process(delta: float) -> void:
	if GameManager.is_placing():
		if timer_active:
			update_timer(delta)

func new_image():
	#Purge old figures
	for o:Control in mirror_parent.get_children():
		o.queue_free()
		
	for i:Control in GameManager.shape_parent.get_children():
		i.queue_free()
		
	var tex = all_images.pop_front()
	display_texture.texture = tex
	viewport_texture.texture = tex
	#reference_texture.texture = tex
	current_texture = tex
	top_level_texture.material.set_shader_parameter("actual_image",tex)
	await get_tree().create_timer(0.4).timeout
	evaluate_image(default_pixels)
	#await get_tree().create_timer(0.5).timeout
	
	
func evaluate_image(p_pixels:AmericanPixels = null):
	if !p_pixels:
		p_pixels = pixels
		
	var image = reference_texture.texture.get_image()
	p_pixels.reset_pixels()
	
	for x in range(image_size):
		for y in range(image_size):
			var pixel_color = image.get_pixel(x,y)
			if pixel_color.get_luminance() > 0.5:
				p_pixels.add_white(1)
				continue
				
			if pixel_color.r > 0.5:
				p_pixels.add_red(1)
				continue
				
			if pixel_color.b > 0.5:
				p_pixels.add_blue(1)
				continue
				
	print("PIXEL INFO!")
	print_rich("[color=RED]Red pixels : %d " % p_pixels.get_red())
	print_rich("[color=BLUE]Blue pixels : %d " % p_pixels.get_blue())
	print_rich("White pixels: %d " % p_pixels.get_white())
	
	calculate_score()
	
	
func calculate_score():
	var red_offset = default_pixels.get_red() - pixels.get_red()
	var white_offset = default_pixels.get_white() - pixels.get_white()
	var blue_offset = default_pixels.get_blue() - pixels.get_blue()
	
	print("SCORE INFO!")
	print_rich("[color=RED]Red pixels : %d " % red_offset)
	print_rich("[color=BLUE]Blue pixels : %d " % blue_offset)
	print_rich("White pixels: %d " % white_offset)
	
	red_score = red_offset * 4.0
	blue_score = blue_offset
	white_score = white_offset * 1.2
	white_score_B = pixels.get_blue() * 0.25

func get_resources_from_folder(path:String,arr_to_populate:Array):
	var dir = DirAccess.open(path)
	if (dir):
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				var full_path = path + file_name#.trim_suffix(".png")
				if !full_path.ends_with(".import"):
					print(full_path)
					arr_to_populate.append(full_path)
					#var resource = load(full_path)
					#if resource:
					#	arr_to_populate.append(resource)
				#arr_to_populate.append(full_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occured while trying to access the path %s" % path)
		return false
		
	return true

func get_resources_from_resource():
	var res:TextureHolder = load("res://art/misc/all_textures.tres")
	all_images = res.images

func popup_status_text(txt:String,hold_time:float = 0.75):
	var status_label:Label = get_node("/root/main/ui/ui_gameplay/status_text_parent/status_label")
	status_label.text = txt
	
	status_label.get_parent().modulate.a = 0.0
	status_label.get_parent().scale = Vector2.ONE * 5.0
	status_label.get_parent().rotation = deg_to_rad(30.0)
	SimonTween.start_tween(status_label.get_parent(),"rotation",0.0,0.35,Global.anim_curves_A.curve_z)
	SimonTween.start_tween(status_label.get_parent(),"modulate:a",1.0,0.25).set_relative(true)
	await SimonTween.start_tween(status_label.get_parent(),"scale",Vector2.ONE,0.2,Global.anim_curves_A.curve_x).tween_finished
	await get_tree().create_timer(hold_time).timeout
	await SimonTween.start_tween(status_label.get_parent(),"modulate:a",0.0,0.25).tween_finished
	status_label.get_parent().scale = Vector2.ONE
	status_label.get_parent().modulate.a = 0.0

func start_timer():
	current_time = 0.0
	timer_active = true

func stop_timer(shapes:bool = false):
	timer_active = false
	if shapes:
		popup_status_text("Out of shapes!")
	else:
		popup_status_text("Time out!")
	Global.timer_end.emit()

func update_timer(delta:float):
	current_time += delta
	update_timer_label()
	
	if current_time > max_time:
		stop_timer()
	
func update_timer_label():
	var t_c = (max_time - floor(current_time))
	if t_c != clamped_time:
		clamped_time = t_c
		SimonTween.start_tween(timer_handle.get_node("timer_label"),"position:y",-15.0,0.3,Global.anim_curves_A.curve_y).set_relative(true).set_start_snap(true)
		timer_handle.get_node("timer_label").text = "%d" % clamped_time

func update_shapes_place_label():
	get_node("/root/main/ui/ui_gameplay/shapes_used_label").text = "%d / %d" % [shapes_placed, max_shapes_placed]

func add_shape_placed():
	shapes_placed += 1
	update_shapes_place_label()
	
	if shapes_placed >= max_shapes_placed:
		stop_timer(true)

func on_gameplay_started():
	start_gameplay()

func on_texture_ready(vp:ViewportTextureController,image_parent:Control):
	viewport_texture = vp
	mirror_parent = image_parent

func on_shape_placed():
	ImageManager.evaluate_image()
	add_shape_placed()

func on_timer_end():
	GameManager.gameplay_placing_end()
	stop_gameplay()
