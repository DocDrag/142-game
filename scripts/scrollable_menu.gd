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

func _ready():
	var options: Array
	for i in range(1, 10):
		options.append(new_option("test"+str(i), "res://Assets/Picture/button/btnSubmit.png"))
	
	var per = 70
	ScrollableMenu(options, Vector2(percent(1115, per), percent(309, per)))
	
	# เพิ่ม shader material ให้กับ ViewportContainer
	var shader = load("res://Assets/theme/fade_shader.gdshader")
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("fade_height", 0.1)  # ปรับค่านี้ตามต้องการ
	viewport_container.material = material

func percent(total: float, per: float):
	if total == 0:
		return total
	per = per / 100
	var result = round(total * per)
	return result

func ScrollableMenu(options: Array, button_size: Vector2, set_speed_scroll = 30):
	speed_scroll = set_speed_scroll
	print("Button size: ", button_size)
	create_options(options, button_size)

func new_option(name: String, position_picture: String) -> Dictionary:
	var option: Dictionary = {
		"name": name,
		"position_picture": position_picture
	}
	return option

func create_options(options, button_size: Vector2):
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()
	
	for option in options:
		var button = button_scene.instantiate()
		button.name = option["name"]
		var icon_path = String(option["position_picture"])
		if ResourceLoader.exists(icon_path):
			button.icon = load(icon_path)
		else:
			print("Icon not found: %s" % icon_path)
		
		button.pressed.connect(_on_button_pressed.bind(option["name"]))
		
		button.set_custom_minimum_size(button_size)
		button.set_size(button_size)
		
		vbox.add_child(button)
		
		button.call_deferred("set_custom_minimum_size", button_size)
		button.call_deferred("set_size", button_size)
	
	call_deferred("update_scroll_container_size")

func _on_button_pressed(option_name):
	print("Button pressed: %s" % option_name)

func update_scroll_container_size():
	scroll_container.set_size(Vector2(vbox.get_combined_minimum_size().x, 1080))
	viewport.size = scroll_container.size
	viewport_container.set_size(scroll_container.size)

func _input(event):
	if not viewport_container.get_global_rect().has_point(get_global_mouse_position()):
		return

	var mouse_position = get_local_mouse_position()
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			scroll_y = max(0, scroll_y - speed_scroll)
			scroll_container.set_v_scroll(scroll_y)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			scroll_y = min(scroll_container.get_v_scroll_bar().max_value, scroll_y + speed_scroll)
			scroll_container.set_v_scroll(scroll_y)

		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				drag_target = get_drag_target(mouse_position)
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

func get_drag_target(mouse_position: Vector2) -> Button:
	for button in vbox.get_children():
		if button is Button and button.get_global_rect().has_point(get_global_mouse_position()):
			return button
	return null
