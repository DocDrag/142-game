extends Control

const GEM_PER_CORRECT = 100
const GEM_PER_INCORRECT = -100

@export var json_path: String = "res://questions.json"
var questions: Array = []

var shuffled_questions = []
var current_question_index = 0
var score = 0
var max_timer = 60 # วินาที
var time_per_question = 1 # วินาที

@onready var labelQuestion = $Question
@onready var buttonChoices = [$ButtonA, $ButtonB, $ButtonC]
@onready var labelFeedback = $Feedback
@onready var scoreLable = $Score
@onready var restart_button = $RestartButton
@onready var image_rect = $normal

@onready var timer = $Timer
@onready var timerLabel = $TimeCounter

@onready var warn_true = $warn_true
@onready var warn_false = $warn_false

# เก็บ ID ของผู้เล่นที่ใช้งานอยู่
var NowUseID = 0


func _ready():
	load_questions()
	restart_button.pressed.connect(restart_game)
	timerLabel.text = ""
	set_default_color_and_image()
	start_game()
	
func load_questions():
	var f = FileAccess.open(json_path, FileAccess.READ)
	var text = f.get_as_text()
	f.close()

	var j = JSON.new()
	var err = j.parse(text)
	if err != OK:
		push_error("JSON parse error: %s" % j.get_error_message())
		return

	questions = j.data

func _process(_delta: float) -> void:
	var time_left = timer.time_left
	var minutes = int(time_left / 60)
	var seconds = int(time_left) % 60
	var microseconds = int((time_left - int(time_left)) * 1000)

	if minutes < 1 and seconds <= 10:
		timerLabel.text = "เวลาคงเหลือ: %02d.%03d" % [seconds, microseconds]
	else:
		timerLabel.text = "เวลาคงเหลือ: %02d:%02d" % [minutes, seconds]

	if time_left <= 0.0:
		current_question_index = shuffled_questions.size()
		timer.stop()
		load_question()
		labelQuestion.text = "เวลาหมดแล้ว!!!"
		scoreLable.text = "คะแนน: %d" % score
		timerLabel.text = ""
		
	
	if not $SQLiteManager.is_not_system_in_database():
		NowUseID = $SQLiteManager.get_data_system()["NowUseID"]
		var Gem = $SQLiteManager.get_data_player(NowUseID)["Gem"]
		$"Gem Frame".update_gem(Gem)
		
		if warn_true.position.y > 0:
			warn_true.position.y -= 1
		
		if warn_false.position.y > 0:
			warn_false.position.y -= 1

func start_game():
	timerLabel.text = "เวลาคงเหลือ: " 
	restart_button.visible = false
	shuffled_questions = questions.duplicate()
	shuffled_questions.shuffle()
	current_question_index = 0
	timer.one_shot = true
	timer.wait_time = max_timer
	timer.start()
	warn_true.text = ""
	warn_false.text = ""
	load_question()

func restart_game():
	score = 0
	start_game()

func load_question():
	set_default_color_and_image()
	
	scoreLable.text = "คะแนน: %d" % score
	if current_question_index >= shuffled_questions.size():
		# labelQuestion.text = "🎉 คุณตอบคำถามครบแล้ว! คะแนนของคุณ: %d" % score
		labelQuestion.text = ""
		labelFeedback.text = ""
		for button in buttonChoices:
			button.visible = false
		restart_button.visible = true
		return

	var question_data = shuffled_questions[current_question_index]
	labelQuestion.text = "ข้อที่ %d: %s" % [min(current_question_index + 1, shuffled_questions.size()), question_data["question"]]

	var keys = ["A", "B", "C"]
	for i in keys.size():
		var key = keys[i]
		var btn = buttonChoices[i]
		btn.visible = false
		btn.text = "%s" % question_data["options"][key]
		if btn.pressed.is_connected(handle_answer_wrapper):
			btn.pressed.disconnect(handle_answer_wrapper)
		btn.pressed.connect(handle_answer_wrapper.bind(key))
		btn.visible = true

	labelFeedback.text = ""

func handle_answer_wrapper(selected_key: String):
	handle_answer(selected_key)

func handle_answer(selected_key: String):
	var question_data = shuffled_questions[current_question_index]
	var answer_key = question_data["answer"]
	if selected_key == answer_key:
		labelFeedback.text = "✅ ถูกต้อง!!"
		score += question_data["points"]
		scoreLable.text = "คะแนน: %d" % score
	else:
		labelFeedback.text = "❌ ผิดนะ คำตอบที่ถูกคือ: %s" % question_data["options"][answer_key]

	set_background_image(selected_key, selected_key == answer_key)

	current_question_index += 1
	await get_tree().create_timer(time_per_question).timeout
	load_question()

func set_button_color(name_str: String, color_code: String):
	var color = Color(color_code)
	for btn in buttonChoices:
		btn.add_theme_color_override(name_str, color)

func set_all_labels_color(name_str: String, color_code: String):
	var color = Color(color_code)
	labelQuestion.add_theme_color_override(name_str, color)
	labelFeedback.add_theme_color_override(name_str, color)
	scoreLable.add_theme_color_override(name_str, color)



func set_background_image(choice: String, is_correct: bool):
	var Gem = $SQLiteManager.get_gem(NowUseID)
	
	var disabled_color = Color("#1234FF")
	var choiced_color = Color("#1234FF") # black green
	var btn_index = 0
	if is_correct:
		if choice == "A":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกซ้าย.png")
			btn_index = 0
		elif choice == "B":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกกลาง.png")
			btn_index = 1
		elif choice == "C":
			image_rect.texture = load("res://assets/quiz_game/ตอบถูกขวา.png")
			btn_index = 2
		disabled_color =  Color("#000000")	
		choiced_color = Color("#00FF00")
		
		# ตั้งค่าสีเป็นสีเขียว และแสดงข้อความ +100
		warn_true.position = buttonChoices[btn_index].position
		warn_true.text = str("+%s" % GEM_PER_CORRECT)
		$SQLiteManager.update_gem(NowUseID, (Gem + GEM_PER_CORRECT))
		
		# เรียกใช้งาน AnimationPlayer สำหรับ warn_true
		warn_true.get_node("AnimationPlayer").play("out_warn")
		
		# ล้างข้อความหลังจาก 1 วินาที
		await get_tree().create_timer(1.0).timeout
		warn_true.text = ""
	else:
		if choice == "A":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดซ้าย.png")
			btn_index = 0
		elif choice == "B":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดกลาง.png")
			btn_index = 1
		elif choice == "C":
			image_rect.texture = load("res://assets/quiz_game/ตอบผิดขวา.png")
			btn_index = 2
		set_all_labels_color("font_color", "#FFFFFF")
		set_button_color("font_color", "#FFFFFF")
		set_button_color("font_focus_color", "#FFFFFF")
		disabled_color = Color("#FF0000")
		choiced_color = Color("#FFFFFF")
		
		# ตั้งค่าสีเป็นสีแดง และแสดงข้อความ -5
		warn_false.position = buttonChoices[btn_index].position
		warn_false.text = str("%s" % GEM_PER_INCORRECT)
		$SQLiteManager.update_gem(NowUseID, (Gem + GEM_PER_INCORRECT))
		
		# เรียกใช้งาน AnimationPlayer สำหรับ warn_true
		warn_false.get_node("AnimationPlayer").play("out_warn")
		
		# ล้างข้อความหลังจาก 1 วินาที
		await get_tree().create_timer(1.0).timeout
		warn_false.text = ""

	for btn in buttonChoices:
		btn.add_theme_color_override("font_disabled_color", disabled_color)
		btn.disabled = true

	buttonChoices[btn_index].add_theme_color_override("font_disabled_color", choiced_color)

func set_default_color_and_image():
	image_rect.texture = load("res://assets/quiz_game/question_screen.png")
	set_all_labels_color("font_color", "#000000")
	set_button_color("font_color", "#000000")
	set_button_color("font_disabled_color", "#1234FF")

	# func set_button_hover_font_color():
	var hover_color = Color("#a3a3a3")
	for btn in buttonChoices:
		btn.add_theme_color_override("font_color_hover", hover_color)
		btn.disabled = false

func time_left_to_live() -> Array:
	var timeleft = timer.time_left
	var minutes = float(timeleft / 60)
	var seconds = int(timeleft) % 60
	var microseconds = int(timeleft * 1000) % 1000
	return [minutes, seconds, microseconds]


func _on_btn_back_pressed() -> void:
	score = 0
	get_tree().change_scene_to_file("res://Scenes/game_selection.tscn")
