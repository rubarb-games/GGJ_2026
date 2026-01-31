class_name AmericanPixels extends RefCounted

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
