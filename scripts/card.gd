extends Area2D

@onready var sprite_card = $Sprite2D  # เรียกใช้ Sprite2D ของการ์ด

# ตัวแปรสำหรับเก็บภาพด้านหน้าและด้านหลังของการ์ด
var front_texture: Texture2D
var back_texture: Texture2D
# ตรวจสอบสถานะคว่ำการ์ด
var is_face_down = true
# การพลิกการ์ด
const start_flip = 80
const end_flip = 100
var flip_progress = start_flip
var flip_speed = 50

# ฟังก์ชันเริ่มต้นเมื่อการ์ดพร้อม
func _ready():
	back_texture = preload("res://Assets/Picture/character/card/back_card.png")
	sprite_card.texture = front_texture  # ตั้งค่าภาพเริ่มต้นเป็นภาพด้านหน้า
	flip_progress = start_flip

# ฟังก์ชันสำหรับสั่งให้การ์ดพลิก
func flip():
	is_face_down = !is_face_down
	flip_progress = start_flip

# ฟังก์ชันที่ทำงานทุกเฟรมสำหรับการจัดการการพลิกการ์ด
func _process(delta):
	if flip_progress <= end_flip:
		flip_progress += flip_speed * delta
		
		if flip_progress > end_flip:
			flip_progress = end_flip  # หยุดการหมุนเมื่อถึง 100
		
		if flip_progress < 90:
			# ปรับขนาดการ์ดในแกน x ขณะพลิก
			sprite_card.scale.x = abs(cos(deg_to_rad(flip_progress)))
		else:
			# เปลี่ยนภาพขณะพลิกถึงครึ่งทางและขยายขนาดกลับ
			sprite_card.texture = back_texture if is_face_down else front_texture
			sprite_card.scale.x = abs(cos(deg_to_rad(180 - flip_progress)))

# ฟังก์ชันสำหรับตั้งค่าภาพการ์ดด้านหน้า
func set_card_textures(front_img: Texture2D):
	front_texture = front_img

func get_card_texture() -> Texture2D:
	return front_texture
