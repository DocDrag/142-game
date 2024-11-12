extends Control

@onready var viewport_container := $ViewportContainer
@onready var viewport := $ViewportContainer/Viewport
@onready var scroll_container := $ViewportContainer/Viewport/ScrollContainer
@onready var vbox := $ViewportContainer/Viewport/ScrollContainer/VBoxContainer
@onready var button_scene := preload("res://Scenes/button_properties.tscn")

var scroll_y := 0
var speed_scroll: int = 30
var dragging: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO
var drag_target: Button = null

# เก็บค่าของปุ่มที่กดล่าสุด
var button_use = null

func _ready():
	# Test
	#var options: Array
	#for i in range(1, 10):
		#options.append(new_option("test"+str(i), "res://Assets/Picture/gacha/banner/banner_Debirun.png"))
	#
	#var per = 50
	#ScrollableMenu(options, Vector2(percent(1280, per), percent(600, per)))
	
	# เพิ่ม shader material ให้กับ ViewportContainer
	var shader = load("res://Assets/theme/fade_shader.gdshader")
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("fade_height", 0.3)  # ปรับค่านี้ตามต้องการ
	viewport_container.material = material

func percent(total: float, per: float):
	if total == 0:
		return total
	per = per / 100
	var result = round(total * per)
	return result

func ScrollableMenu(options: Array, button_size: Vector2, set_speed_scroll = 30):
	speed_scroll = set_speed_scroll
	# print("Button size: ", button_size)
	_create_options(options, button_size)

func new_option(name: String, position_picture: String) -> Dictionary:
	var option: Dictionary = {
		"name": name,
		"position_picture": position_picture
	}
	return option

func _create_options(options, button_size: Vector2):
	# ล้างปุ่มเก่าที่มีอยู่
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	
	# คำนวณ margin
	var margin = button_size.y

	# เพิ่มพื้นที่ว่างที่ด้านบน
	var top_margin = Control.new()
	top_margin.set_custom_minimum_size(Vector2(0, margin))
	vbox.add_child(top_margin)

	# ให้ปุ่มเริ่มต้นที่เลือกใช้เป็นปุ่มแรกสุดเสมอ
	button_use = options[0]["name"]
	
	# เพิ่มปุ่ม
	for option in options:
		var button = button_scene.instantiate()
		button.name = option["name"]
		var icon_path = String(option["position_picture"])
		if ResourceLoader.exists(icon_path):
			button.icon = load(icon_path)
		else:
			print("Icon not found: %s" % icon_path)
		
		button.pressed.connect(on_button_pressed.bind(option["name"]))
		
		button.set_custom_minimum_size(button_size)
		button.set_size(button_size)
		
		vbox.add_child(button)
		
		button.call_deferred("set_custom_minimum_size", button_size)
		button.call_deferred("set_size", button_size)

	# เพิ่มพื้นที่ว่างที่ด้านล่าง
	var bottom_margin = Control.new()
	bottom_margin.set_custom_minimum_size(Vector2(0, margin))
	vbox.add_child(bottom_margin)
	
	call_deferred("_update_scroll_container_size")

func on_button_pressed(option_name):
	# บันทึกปุ่มที่กดปัจจุบัน
	button_use = option_name

func _update_scroll_container_size():
	scroll_container.set_size(Vector2(vbox.get_combined_minimum_size().x, 1080))
	viewport.size = scroll_container.size
	viewport_container.set_size(scroll_container.size)

func handle_event(event):
	var mouse_position = get_local_mouse_position()
	
	if event is InputEventMouseButton:
		if viewport_container.get_global_rect().has_point(get_global_mouse_position()):
			# อนุญาตให้ใช้ลูกกลิ้งเมาส์เมื่ออยู่บนวัตถุเท่านั้น
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				scroll_y = max(0, scroll_y - speed_scroll)
				scroll_container.set_v_scroll(scroll_y)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				scroll_y = min(scroll_container.get_v_scroll_bar().max_value, scroll_y + speed_scroll)
				scroll_container.set_v_scroll(scroll_y)

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				drag_target = _get_drag_target(mouse_position)
				if drag_target:
					dragging = true
					last_mouse_position = mouse_position
				else:
					dragging = false
			else:
				dragging = false
				drag_target = null
	
	if dragging and event is InputEventMouseMotion and drag_target:
		var delta = mouse_position - last_mouse_position
		scroll_y = clamp(scroll_y - delta.y, 0, scroll_container.get_v_scroll_bar().max_value)
		scroll_container.set_v_scroll(scroll_y)
		last_mouse_position = mouse_position
		
	
	if button_use != null:
		var raw_button_use = button_use
		button_use = null
		return raw_button_use
	else:
		return button_use

func _get_drag_target(mouse_position: Vector2) -> Button:
	for button in vbox.get_children():
		if button is Button and button.get_global_rect().has_point(get_global_mouse_position()):
			return button
	return null
