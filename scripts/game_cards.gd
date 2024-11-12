extends Node2D

const CARD_PAIRS = 6
const SHOW_CARDS_TIME = 2.0

var cards = []
var selected_cards = []
var can_flip = false

# เก็บ ID ของผู้เล่นที่ใช้งานอยู่
var NowUseID = 0

@onready var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var warn_true = $warn_true
@onready var warn_false = $warn_false

func _ready():
	randomize()
	create_cards()
	show_cards_initially()
	warn_true.text = ""
	warn_false.text = ""

func _process(delta):
	if not $SQLiteManager.is_not_system_in_database():
		NowUseID = $SQLiteManager.get_data_system()["NowUseID"]
		var Gem = $SQLiteManager.get_data_player(NowUseID)["Gem"]
		$"Gem Frame".update_gem(Gem)
		
		if warn_true.position.y > 0:
			warn_true.position.y -= 1
		
		if warn_false.position.y > 0:
			warn_false.position.y -= 1
		
func percent(total: float, per: float):
	if total == 0:
		return total
	per = per / 100
	var result = round(total * per)
	return result

func create_cards():
	var card_scene = preload("res://Scenes/card.tscn")
	var card_textures = load_card_textures()

	var card_width = percent(1536, 20)   # ปรับขนาดตามต้องการ
	var card_height = percent(2048, 20)  # ปรับขนาดตามต้องการ
	var col = 6
	var row = 2
	# คำนวณขนาดหน้าจอเพื่อจัดวางวัตถุ
	var interval = 100 # พื้นที่ในส่วนของขอบบนสำหรับปุ่มออกและ Gem
	var h_spacing = int((screen_width - (col * card_width)) / (col+1))
	var v_spacing = int(((screen_height-interval) - (row * card_height)) / (row+1))
	
	var key = 0
	for i in range(CARD_PAIRS):
		for j in range(2):
			var card = card_scene.instantiate()
			card.set_card_textures(card_textures[key])
			var x = (i * card_width) + (h_spacing * (i+1))
			var y = ((j * card_height) + (v_spacing * (j+1))) + interval
			card.position = Vector2(x, y)
			card.input_event.connect(_on_Card_input_event.bind(card))
			cards.append(card)
			$Cards.add_child(card)
			key += 1

func load_card_textures():
	var textures = []
	for i in range(2):
		for j in range(CARD_PAIRS):
			textures.append(load("res://Assets/Picture/character/card/card_" + str(j+1) + ".png"))
	textures.shuffle()
	return textures

func show_cards_initially():
	for card in cards:
		card.flip() 
	
	await get_tree().create_timer(SHOW_CARDS_TIME).timeout
	
	for card in cards:
		card.flip()
	
	can_flip = true

func _on_Card_input_event(viewport, event, shape_idx, card):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and can_flip:
		if not card.is_face_down:
			return
		
		card.flip()
		selected_cards.append(card)
		
		if len(selected_cards) >= 2:
			check_match()

func check_match():
	var Gem = $SQLiteManager.get_gem(NowUseID)
	
	var first_card = selected_cards[0]
	var second_card = selected_cards[1]
	selected_cards.erase(first_card)
	selected_cards.erase(second_card)
	
	if first_card.get_card_texture() == second_card.get_card_texture():
		await get_tree().create_timer(0.5).timeout
		first_card.queue_free()
		second_card.queue_free()
		
		# ตั้งค่าสีเป็นสีเขียว และแสดงข้อความ +5
		warn_true.position = second_card.position
		warn_true.text = "+5"
		$SQLiteManager.update_gem(NowUseID, (Gem + 5))
		
		# เรียกใช้งาน AnimationPlayer สำหรับ warn_true
		warn_true.get_node("AnimationPlayer").play("out_warn")
		
		# ล้างข้อความหลังจาก 1 วินาที
		await get_tree().create_timer(1.0).timeout
		warn_true.text = ""
		
		cards.erase(first_card)
		cards.erase(second_card)
	else:
		await get_tree().create_timer(1.0).timeout
		first_card.flip()
		second_card.flip()
		
		# ตั้งค่าสีเป็นสีแดง และแสดงข้อความ -5
		warn_false.position = second_card.position
		warn_false.text = "-5"
		$SQLiteManager.update_gem(NowUseID, (Gem - 5))
		
		# เรียกใช้งาน AnimationPlayer สำหรับ warn_true
		warn_false.get_node("AnimationPlayer").play("out_warn")
		
		# ล้างข้อความหลังจาก 1 วินาที
		await get_tree().create_timer(1.0).timeout
		warn_false.text = ""
	
	first_card = null
	second_card = null
	can_flip = true
	
	if cards.is_empty():
		get_tree().change_scene_to_file("res://Scenes/game_selection.tscn")


func _on_btn_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/game_selection.tscn")
