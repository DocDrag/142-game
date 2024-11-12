extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$ReferenceRect.hide()
	$bg_mission/missionAnimation.play("FadeIn")
	

func _process(delta):
	if not $SQLiteManager.is_not_system_in_database():
		var NowUseID = $SQLiteManager.get_data_system()["NowUseID"]
		var Gem = $SQLiteManager.get_data_player(NowUseID)["Gem"]
		$"Gem Frame".update_gem(Gem)
		
		
func _on_btn_back_pressed():
	# สั่งเล่น Animation
	$ReferenceRect.hide()
	$bg_earth/BgAnimation.play("animation_down")
	$bg_mission/missionAnimation.play("FadeOut")


func _on_btn_play_card_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_cards.tscn")


func _on_btn_play_ans_pressed():
	pass # Replace with function body.


func _on_btn_play_vs_mons_pressed():
	pass # Replace with function body.


func _on_mission_animation_animation_finished(anim_name):
	if anim_name == "FadeIn":
		$ReferenceRect.show()


func _on_bg_animation_animation_finished(anim_name):
	# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
	if anim_name == "animation_down":
		# Change scene
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
