extends Button

@onready var shader_material := ShaderMaterial.new()  # สร้าง ShaderMaterial ใหม่

func _ready():
	# โหลด shader สำหรับปุ่มนี้โดยเฉพาะ
	shader_material.shader = load("res://Assets/theme/btn_shader.gdshader")
	self.material = shader_material  # กำหนด ShaderMaterial ให้กับปุ่ม

func _on_mouse_entered():
	shader_material.set_shader_parameter("is_hovered", true)
	# ปรับแต่ง Theme หรือ StyleBox
	var style_box = StyleBoxFlat.new()
	style_box.set_content_margin_all(0)
	$".".add_theme_stylebox_override("normal", style_box)

func _on_mouse_exited():
	shader_material.set_shader_parameter("is_hovered", false)
