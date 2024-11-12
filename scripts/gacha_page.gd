extends Control

var banner_gacha_name: String

func _ready():
	var options: Array
	# คำนวนขนาดของรูป โดยอ้างอิงจากขนาดรูปเดิม
	var per = 50
	var button_size = Vector2($scrollable_menu.percent(1280, per), $scrollable_menu.percent(600, per))
	options.append($scrollable_menu.new_option("Rate-Up ALL", "res://Assets/Picture/gacha/banner/banner_All.png"))
	options.append($scrollable_menu.new_option("Rate-Up Beta AMI", "res://Assets/Picture/gacha/banner/banner_AMI.png"))
	options.append($scrollable_menu.new_option("Rate-Up T-Reina Ashyra", "res://Assets/Picture/gacha/banner/banner_Ashyra.png"))
	options.append($scrollable_menu.new_option("Rate-Up Debirun", "res://Assets/Picture/gacha/banner/banner_Debirun.png"))
	options.append($scrollable_menu.new_option("Rate-Up Mild-R", "res://Assets/Picture/gacha/banner/banner_Mild-R.png"))
	options.append($scrollable_menu.new_option("Rate-Up Kumoku Tsururu", "res://Assets/Picture/gacha/banner/banner_Tsururu.png"))
	options.append($scrollable_menu.new_option("Rate-Up Xonebu X'thulhu", "res://Assets/Picture/gacha/banner/banner_Xonebu.png"))
	$scrollable_menu.ScrollableMenu(options, button_size)
	
	
func _process(delta):
	if not $SQLiteManager.is_not_system_in_database():
		var NowUseID = $SQLiteManager.get_data_system()["NowUseID"]
		var Gem = $SQLiteManager.get_data_player(NowUseID)["Gem"]
		$"Gem Frame".update_gem(Gem)
		
		
func _on_btn_back_pressed():
	# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _input(event):
	var button_use = $scrollable_menu.handle_event(event)
	if button_use != null:
		banner_gacha_name = button_use


func _on_btn_1_roll_pressed():
	print(banner_gacha_name)


func _on_btn_10_roll_pressed():
	print(banner_gacha_name)
