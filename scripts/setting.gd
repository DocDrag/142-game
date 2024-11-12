extends Control

# การตั้งค่าขนาดหน้าจอ
@onready var dropdown: OptionButton = $ResolutionDropdown

# การตั้งค่าเสียง
@onready var bgm_slider: HSlider = $BackgroundMusicSlider
@onready var sfx_slider: HSlider = $SoundEffectsSlider
@onready var bgm_label: Label = $BackgroundMusicLabel
@onready var sfx_label: Label = $SoundEffectsLabel

func _ready():
	# ตั้งค่าเสียงเป็นค่าพื้นฐาน
	# AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), 0)
	
	# ตั้งค่า Slider ให้ตรงกับค่าเสียงปัจจุบัน
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("BGM"))) * 100
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))) * 100

	_update_bgm_label()
	_update_sfx_label()

func _on_bgm_volume_changed(value: float):
	var bus_index = AudioServer.get_bus_index("BGM")
	# แปลงจากเปอร์เซ็นต์เป็น dB
	var db_value = linear_to_db(value / 100)
	AudioServer.set_bus_volume_db(bus_index, db_value)
	_update_bgm_label()

func _on_sfx_volume_changed(value: float):
	var bus_index = AudioServer.get_bus_index("SFX")
	# แปลงจากเปอร์เซ็นต์เป็น dB
	var db_value = linear_to_db(value / 100)
	AudioServer.set_bus_volume_db(bus_index, db_value)
	_update_sfx_label()

func _update_bgm_label():
	var volume = int(bgm_slider.value)
	bgm_label.text = str(volume) + "%"

func _update_sfx_label():
	var volume = int(sfx_slider.value)
	sfx_label.text = str(volume) + "%"

func _on_resolution_selected(index):
	match index:
		1: # Full Screen
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		2: # 1920x1080
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		3: # 1280x720
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(1280, 720))
		4: # 854x480
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(Vector2i(854, 480))

func _on_btn_back_pressed():
	# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")
