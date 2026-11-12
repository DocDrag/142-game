extends Node2D

const CARD_PAIRS = 6
const SHOW_CARDS_TIME = 2.0
const GEM_PER_CORRECT = 5
const GEM_PER_INCORRECT = -5
const GAME_SELECTION_SCENE = "res://Scenes/game_selection.tscn"

var cards = []
var selected_cards = []
var can_flip = false

# เก็บ ID ของผู้เล่นที่ใช้งานอยู่
var NowUseID = -1
var current_gem = 0

@onready var screen_width = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var screen_height = ProjectSettings.get_setting("display/window/size/viewport_height")
@onready var warn_true = $warn_true
@onready var warn_false = $warn_false

func _ready():
	randomize()
	ResourceLoader.load_threaded_request(GAME_SELECTION_SCENE)
	NowUseID = $SQLiteManager.get_active_player_id()
	if NowUseID != -1:
		current_gem = $SQLiteManager.get_gem(NowUseID)
		$"Gem Frame".update_gem(current_gem)
	_connect_warn_cleanup(warn_true)
	_connect_warn_cleanup(warn_false)
	create_cards()
	show_cards_initially()
	warn_true.text = ""
	warn_false.text = ""

func _process(_delta):
	if warn_true.text != "" and warn_true.position.y > 0:
		warn_true.position.y -= 1
	
	if warn_false.text != "" and warn_false.position.y > 0:
		warn_false.position.y -= 1

func _connect_warn_cleanup(label: Label):
	var anim_player: AnimationPlayer = label.get_node("AnimationPlayer")
	anim_player.animation_finished.connect(func(_anim_name):
		if not anim_player.is_playing():
			label.text = ""
	)

func _show_warn(label: Label, pos: Vector2, text: String):
	label.position = pos
	label.text = text
	var anim_player: AnimationPlayer = label.get_node("AnimationPlayer")
	anim_player.stop()
	anim_player.play("out_warn")

func _apply_gem_delta(delta_gem: int):
	current_gem += delta_gem
	if NowUseID > 0:
		$SQLiteManager.update_gem(NowUseID, current_gem)
	$"Gem Frame".update_gem(current_gem)
		
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
	if not is_inside_tree():
		return
	
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
	var first_card = selected_cards[0]
	var second_card = selected_cards[1]
	selected_cards.erase(first_card)
	selected_cards.erase(second_card)
	
	if first_card.get_card_texture() == second_card.get_card_texture():
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree() or not is_instance_valid(first_card) or not is_instance_valid(second_card):
			return
		var warn_pos = second_card.position
		first_card.queue_free()
		second_card.queue_free()
		cards.erase(first_card)
		cards.erase(second_card)
		
		# อัปเดต Gem ทันทีเมื่อจับคู่ถูก
		_apply_gem_delta(GEM_PER_CORRECT)
		
		if cards.is_empty():
			_go_to_game_selection()
			return
		
		# แสดงข้อความ +5 และเล่นแอนิเมชันโดยไม่รอ block เกม
		_show_warn(warn_true, warn_pos, str("+%s" % GEM_PER_CORRECT))
	else:
		await get_tree().create_timer(1.0).timeout
		if not is_inside_tree() or not is_instance_valid(first_card) or not is_instance_valid(second_card):
			return
		first_card.flip()
		second_card.flip()
		
		# อัปเดต Gem และแสดงข้อความ -5 โดยไม่รอ block เกม
		_apply_gem_delta(GEM_PER_INCORRECT)
		_show_warn(warn_false, second_card.position, str("%s" % GEM_PER_INCORRECT))
	
	first_card = null
	second_card = null

func _go_to_game_selection():
	var status = ResourceLoader.load_threaded_get_status(GAME_SELECTION_SCENE)
	if status == ResourceLoader.THREAD_LOAD_LOADED or status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		var packed_scene = ResourceLoader.load_threaded_get(GAME_SELECTION_SCENE)
		if packed_scene is PackedScene:
			get_tree().change_scene_to_packed(packed_scene)
			return
	get_tree().change_scene_to_file(GAME_SELECTION_SCENE)


func _on_btn_back_pressed():
	_go_to_game_selection()
