extends AudioStreamPlayer2D

@onready var bgm_player = $"."

func _ready():
	# ตั้งค่าความดังเสียงเป็นค่าพื้นฐาน 10 %
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), -20)
	
	# เข้าถึง stream เพื่อเปิด loop
	var stream = bgm_player.stream
	if stream is AudioStream:
		stream.loop = true
	bgm_player.play()
