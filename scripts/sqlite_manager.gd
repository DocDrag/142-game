extends Node2D

var db : SQLite

func _ready():
	var query : String
	
	# สร้างหรือตรวจสอบฐานข้อมูล
	db = SQLite.new()
	db.path = "res://database.sqlite"
	db.open_db()
	
	# สร้างตาราง System ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS System (
		PRIMARY_KEY INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		NowUseID INTEGER
	);
	"""
	db.query(query)
	
	# สร้างตาราง Players ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Players (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Name TEXT,
		Gem INTEGER DEFAULT 0
	);
	"""
	db.query(query)
	
# ฟังก์ชันเพื่อเพิ่มผู้เล่น
func add_player(name: String, gem: int):
	var ID = -1
	var query = "INSERT INTO Players (Name, Gem) VALUES (?, ?);"
	if db.query_with_bindings(query, [name, gem]):
		ID = db.last_insert_rowid # บันทึกค่า ID ของผู้เล่นที่เพิ่งถูกเพิ่ม
		query = "INSERT INTO System (NowUseID) VALUES (?);"
		# บันทึก ID ปัจจุบัน
		db.query_with_bindings(query, [ID])

# ฟังก์ชันเพื่อตรวจสอบว่าตาราง Players ว่างหรือไม่
func is_not_player_in_database() -> bool:
	var query = "SELECT COUNT(*) as player_count FROM Players;"
	if db.query(query):
		var results = db.query_result
		if results.size() > 0:
			var count = results[0]["player_count"]
			return int(count) == 0 # ถ้า count เป็น 0 แสดงว่าตารางว่าง
	return false # ถ้ามีข้อผิดพลาดในการ query หรือ count ไม่ใช่ 0

# ฟังก์ชันเพื่อตรวจสอบว่าตาราง System ว่างหรือไม่
func is_not_system_in_database() -> bool:
	var query = "SELECT COUNT(*) as system_count FROM System;"
	if db.query(query):
		var results = db.query_result
		if results.size() > 0:
			var count = results[0]["system_count"]
			return int(count) == 0 # ถ้า count เป็น 0 แสดงว่าตารางว่าง
	return false # ถ้ามีข้อผิดพลาดในการ query หรือ count ไม่ใช่ 0
	
# ฟังก์ชันดึงค่าจาก system
func get_data_system() -> Dictionary:
	var query = "SELECT * FROM System;"
	if db.query(query):
		var results = db.query_result
		if results.size() > 0:
			return results[0]  # ส่งคืน Dictionary ที่มีข้อมูลในแถวแรก
	return {}  # ส่งคืน Dictionary ว่าง ถ้าไม่มีข้อมูลหรือมีข้อผิดพลาด

# ฟังก์ชันดึงค่าจาก player
func get_data_player(player_id: int) -> Dictionary:
	var query = "SELECT * FROM Players WHERE ID = ?;"
	if db.query_with_bindings(query, [player_id]):
		var results = db.query_result
		if results.size() > 0:
			return results[0]  # ส่งคืน Dictionary ที่มีข้อมูลของผู้เล่นตาม ID ที่กำหนด
	return {}  # ส่งคืน Dictionary ว่าง ถ้าไม่มีข้อมูลสำหรับ ID ที่กำหนดหรือมีข้อผิดพลาด

# ฟังก์ชันดึงค่า gem จาก player
func get_gem(player_id: int) -> int:
	var query = "SELECT Gem FROM Players WHERE ID = ?;"
	# ดำเนินการ query และตรวจสอบผลลัพธ์
	if db.query_with_bindings(query, [player_id]):
		var results = db.query_result
		if results.size() > 0:
			var gem_value = results[0].get("Gem", 0)  # ใช้ get() เพื่อป้องกันข้อผิดพลาดถ้าคีย์ไม่เจอ
			return int(gem_value)
	return 0  # ส่งคืน 0 ถ้าไม่มีข้อมูลสำหรับ ID ที่กำหนดหรือมีข้อผิดพลาด

# ฟังก์ชันอัพเดตค่า gem ของ player
func update_gem(player_id: int, new_gem_value: int):
	# สร้าง query สำหรับการอัปเดตค่า Gem
	var query = "UPDATE Players SET Gem = ? WHERE ID = ?;"

	# อัปเดตค่า Gem ของผู้เล่นตาม player_id ที่ระบุ
	if db.query_with_bindings(query, [new_gem_value, player_id]):
		print("Updated Gem complete")
	else:
		print("Updated Gem Failed")
