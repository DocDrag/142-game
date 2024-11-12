extends Control

@onready var name_input : LineEdit = $NameInput

func _on_btn_submit_pressed():
	var player_name = name_input.text.strip_edges()
	
	if player_name != "":
		# เพิ่มผู้เล่นใหม่ที่มีชื่อที่กรอก และจำนวน Gem เริ่มต้นเป็น 1420
		$SQLiteManager.add_player(player_name, 1420)
		print("Player created with name: %s" % player_name)
		# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
		get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
	else:
		print("Name cannot be empty.")  # แจ้งผู้เล่นว่าชื่อไม่สามารถว่างเปล่าได้
