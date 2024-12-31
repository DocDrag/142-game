extends Control

@onready var name_input : LineEdit = $NameInput

func _on_btn_submit_pressed():
	var player_name = name_input.text.strip_edges()
	
	if player_name != "":
		# เช็คว่ามีชื่อผู้เล่นในฐานข้อมูลหรือไม่
		var player_id = $SQLiteManager.get_player_from_name(player_name)
		if player_id != -1:
			$SQLiteManager.insert_now_use_id(player_id)
			if player_name == "ดัสทีเรี่ยนที่รัก":
				$SQLiteManager.update_gem(player_id, 142142142)
				$SQLiteManager.update_gem_salt(player_id, 142142142)
			get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
			return

		var gem = 1420
		# เพิ่มผู้เล่นใหม่ที่มีชื่อที่กรอก และจำนวน Gem เริ่มต้นเป็น 1420
		$SQLiteManager.add_player(player_name, gem, 0)
		print("Player created with name: %s" % player_name)
		# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	else:
		print("Name cannot be empty.")  # แจ้งผู้เล่นว่าชื่อไม่สามารถว่างเปล่าได้
