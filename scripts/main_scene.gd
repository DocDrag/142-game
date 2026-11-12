extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	BgmAudioStream.set_audio("The world")
	var active_id = $SQLiteManager.get_active_player_id()
	var player_data = $SQLiteManager.get_data_player(active_id) if active_id != -1 else {}
	if $SQLiteManager.is_not_player_in_database() or active_id == -1 or player_data.is_empty():
		get_tree().change_scene_to_file.call_deferred("res://Scenes/create_character.tscn")
		# เปลี่ยนฉากไปยังฉาก create_character.tscn ที่อยู่ในโฟลเดอร์ Scene
	else:
		$"ControlMenu/Gem Frame".update_gem(int(player_data["Gem"]))
		$ControlMenu.hide()
		$bg_lobby/lobbyAnimation.play("FadeIn")


func _on_btn_setting_pressed():
	# เปลี่ยนฉากไปยังฉาก setting.tscn ที่อยู่ในโฟลเดอร์ Scene
	get_tree().change_scene_to_file("res://Scenes/setting.tscn")


func _on_btn_exit_pressed():
	# ออกจากเกม
	get_tree().quit()


func _on_btn_play_pressed():
	$ControlMenu.hide()
	# สั่งเล่น Animation
	$bg_earth/BgAnimation.play("animation_up")
	$bg_lobby/lobbyAnimation.play("FadeOut")
	
func _on_bg_animation_animation_finished(anim_name):
	# เปลี่ยนฉากไปยังฉาก game_selection.tscn ที่อยู่ในโฟลเดอร์ Scene
	if anim_name == "animation_up":
		# Change scene
		get_tree().change_scene_to_file("res://Scenes/game_selection.tscn")


func _on_lobby_animation_animation_finished(anim_name):
	if anim_name == "FadeIn":
		# Change scene
		$ControlMenu.show()


func _on_btn_gacha_pressed():
	get_tree().change_scene_to_file("res://Scenes/gacha_page.tscn")
