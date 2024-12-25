extends Node2D

@onready var BGM = $"."
@onready var bgm_player = $test
var name_audio = ""

func _ready():
	# ตั้งค่า Bus ของ bgm_player เป็น "BGM"
	bgm_player.bus = "BGM"
	
	# ตั้งค่าความดังเสียงเป็นค่าพื้นฐาน 100 %
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), 0)
	
	set_audio("The world")

func set_audio(value):
	# ถ้าชื่อเพลงไม่เหมือนกันห้เปลี่ยนเพลง
	if name_audio != value:
		name_audio = value
		bgm_player.stop() #หยุดเพลงเดิมที่เล่นอยู่

		# เปลี่ยน Stream ของ bgm_player
		bgm_player.stream = BGM.get_node(value).stream

		# ตั้งค่า loop ถ้า Stream มี
		if bgm_player.stream and bgm_player.stream is AudioStream:
			bgm_player.stream.loop = true

		bgm_player.play()
