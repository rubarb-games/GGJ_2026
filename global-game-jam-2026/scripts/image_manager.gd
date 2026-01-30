extends Node

var display_texture:TextureRect
var viewport_texture:TextureRect
var reference_texture:TextureRect
var current_texture:Texture

var all_image_paths:Array[String]
var all_images:Array[Texture]
var image_size:int = 64
var mirror_parent:Control

var shapes_placed:int = 0

var default_pixels:american_pixels
var pixels:american_pixels

class american_pixels:
	var red_pixels:int = 0
	var white_pixels:int = 0
	var blue_pixels:int = 0
	
	func _init(red:int=0,white:int=0,blue:int=0):
		red_pixels = red
		white_pixels = white
		blue_pixels = blue

	func get_red():
		return red_pixels
	
	func get_blue():
		return blue_pixels
	
	func get_white():
		return white_pixels
		
	func reset_pixels():
		red_pixels = 0
		white_pixels = 0
		blue_pixels = 0
		
	func add_red(v:int):
		red_pixels += 1
		
	func add_white(v:int):
		white_pixels += 1
		
	func add_blue(v:int):
		blue_pixels += 1
		
	func assign_pixels(red:int,white:int,blue:int):
		red_pixels = red
		white_pixels = white
		blue_pixels = blue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.viewport_texture_ready.connect(on_texture_ready)
	Global.post_scene_started.connect(on_post_game_started)

func on_post_game_started():
	pass
	#setup()

func get_refs():
	display_texture = get_node("/root/main/backing/texture_image") 
	reference_texture = get_node("/root/main/backing/TextureRect")
	
func setup():
	default_pixels = american_pixels.new()
	pixels = american_pixels.new()
	
	get_refs()
	get_resources_from_folder("res://art/textures/artworks/",all_image_paths)
	for p in all_image_paths:
		var tex = load(p)
		if tex:
			all_images.append(tex)
	
	new_image()

func new_image():
	#var new_image_path = #all_images.pop_front()
	var tex = all_images.pop_front()

	#Purge old figures
	for o:Control in mirror_parent.get_children():
		o.queue_free()
		
	for i:Control in GameManager.shape_parent.get_children():
		i.queue_free()
	
	display_texture.texture = tex
	viewport_texture.texture = tex
	#reference_texture.texture = tex
	current_texture = tex
	await get_tree().create_timer(0.5).timeout
	evaluate_image(default_pixels)
	
	
func evaluate_image(p_pixels:american_pixels = null):
	if !p_pixels:
		p_pixels = pixels
		
	var image = reference_texture.texture.get_image()
	#image.lock()
	
	#var white_pixels = 0
	#var blue_pixels = 0
	#var red_pixels = 0
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

func on_texture_ready(vp:ViewportTextureController,image_parent:Control):
	viewport_texture = vp
	mirror_parent = image_parent
