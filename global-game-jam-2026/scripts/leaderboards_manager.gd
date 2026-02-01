extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("/root/main/ui/ui_end_menu/end_game_button").pressed.connect(on_end_game_pressed)

func setup_player(n:String):
	await Talo.players.identify("itch",n)
	return true
	
func submit_score(score:int):
	await Talo.leaderboards.add_entry("main_leaderboard",score)
	return true

func on_end_game_pressed():
	var player_name = (get_node("/root/main/ui/ui_end_menu/score_textfield") as TextEdit).text
	await setup_player(player_name)
	await submit_score(GameManager.total_score)
	Global.on_restart.emit()

func fetch_leaderboard():
	var parent = get_node("/root/main/ui/ui_start_menu/leaderboard_entries")
	var ref_label:Label = parent.get_node("leaderboard_entry")
	
	await Talo.leaderboards.get_entries("main_leaderboard")
	var is_even:bool = true
	var entries:Array[TaloLeaderboardEntry] = await Talo.leaderboards.get_cached_entries("main_leaderboard")
	var max_entries:int = 10
	var range_count = min(entries.size(),max_entries)
	
	for i:int in range(range_count):
		var e:TaloLeaderboardEntry = entries[i]
		
		var pos:int = e.position + 1
		var player_name:String = e.player_alias.identifier
		var score:int = e.score
		var new_label:Label = parent.get_child(-1).duplicate()
		parent.add_child(new_label)
		new_label.visible = true
		new_label.text = "%d. %s : %d " % [pos,player_name,score]
		
		if is_even:
			new_label.get_child(0).color = Color(0.56, 0.512, 0.475, 1.0)
		else:
			new_label.get_child(0).color = Color(0.882, 0.463, 0.412)
		is_even = !is_even
		
