extends Node2D

var db: SQLite

func _ready():
	var query: String
	
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
		Gem INTEGER DEFAULT 0,
		Salt INTEGER DEFAULT 0
	);
	"""
	db.query(query)

	query = "
		CREATE TABLE IF NOT EXISTS Characters_Type (
			ID INTEGER PRIMARY KEY AUTOINCREMENT,
			Name INTEGER NOT NULL
		);
	"
	db.query(query)

	# สร้างตาราง Characters ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Characters (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Name TEXT NOT NULL,
		Tier_ID INT NOT NULL,
		Characters_Type_ID,
		FOREIGN KEY (Tier_ID) REFERENCES Characters_Tier(ID) ON DELETE CASCADE,
		FOREIGN KEY (Characters_Type_ID) REFERENCES Characters_Type(ID) ON DELETE CASCADE
	);
	"""
	db.query(query)

	# สร้างตาราง Player_Gacha_Detail ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Players_Gacha_Detail (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Banner_Type_ID INTEGER NOT NULL,
		Players_ID INTEGER NOT NULL,
		IsGuaranteed TINYINT DEFAULT (0),
		NumberRoll INTEGER DEFAULT (0),
		FOREIGN KEY (Banner_Type_ID) REFERENCES Banner_Type(ID) ON DELETE CASCADE,
		FOREIGN KEY (Players_ID) REFERENCES Players(ID) ON DELETE CASCADE
	);
	"""
	db.query(query)

	# สร้างตาราง Player_Gacha_Detail ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Players_Gacha_Log (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Players_ID INTEGER  NOT NULL,
		Character_ID INTEGER  NOT NULL,
		Banner_Type_ID INTEGER  NOT NULL,
		Create_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
		FOREIGN KEY (Character_ID) REFERENCES Character(ID) ON DELETE CASCADE,
		FOREIGN KEY (Players_ID) REFERENCES Players(ID) ON DELETE CASCADE,
		FOREIGN KEY (Banner_Type_ID) REFERENCES Banner_Type(ID) ON DELETE CASCADE
	);
	"""
	db.query(query)

	# สร้างตาราง Characters_Tier ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Characters_Tier (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Name TEXT NOT NULL,
		Rate NUMERIC(3, 3) NOT NULL DEFAULT 0.000,
		Salt INTEGER DEFAULT (0)
	);
	"""
	db.query(query)

	# สร้างตาราง Banner_Type ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Banner_Type (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Name TEXT NOT NULL
	);
	"""
	db.query(query)
	
	# สร้างตาราง Banner ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Banner (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Name TEXT NOT NULL,
		IsEnable TINYINT DEFAULT 1,
		Banner_Type_ID INT NOT NULL,
		FOREIGN KEY (Banner_Type_ID) REFERENCES Banner_Type(ID) ON DELETE CASCADE
	);
	"""
	db.query(query)

	# สร้างตาราง Banner_Rate_Up ถ้ายังไม่มี
	query = """
	CREATE TABLE IF NOT EXISTS Banner_Rate_Up (
		ID INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
		Charcter_ID INTEGER NOT NULL,
		Banner_ID INTEGER NOT NULL,
		Probability NUMERIC(3, 2) DEFAULT (1.00),
		FOREIGN KEY (Banner_ID) REFERENCES Banner(ID) ON DELETE CASCADE,
		FOREIGN KEY (Charcter_ID) REFERENCES Character(ID) ON DELETE CASCADE
	);
	"""
	db.query(query)

	# เช้คว่ามีข้อมูลหรือไม่ 
	var check_query = "SELECT COUNT(*) as Count FROM Characters_Tier;"
	var result = db.query(check_query)
	
	# ตรวจสอบว่า query ดึงข้อมูลได้สำเร็จ
	if result and db.query_result:
		var row_count = db.query_result[0].get("Count", 0)
		if row_count == 0:
			insert_start_data()
		else:
			print("There are already rows in the table.")
	else:
		print("Query failed or no data returned.")

func insert_start_data():
	# เพิ่มข้อมูลเริ่มต้น
	mutiple_insert("INSERT INTO Characters_Tier (Name, Rate, Salt) VALUES (?, ?, ?);", [
			["N", 50.000, 1],
			["R", 30.000, 5],
			["SR", 18.438, 10],
			["SSR", 1.420, 25],
			["UR", 0.1420, 50],
	])

	mutiple_insert("INSERT INTO Characters_Type (Name) VALUES (?);",[
		["World-End ชุดปกติ"], ["Mystic ชุดปกติ"], ["World-End ชุดนอน"]
	])

	# Normal - UR อาจจะเป็น อาวุธ หรือ แฟนคลับ
	insert_character([
			["Normal 01", "N", null], ["Normal 02", "N", null], ["Normal 03", "N", null], ["Normal 04", "N", null],
			["Rare 01", "R", null], ["Rare 02", "R", null], ["Rare 03", "R", null], ["Rare 04", "R", null],
			["SR 01", "SR", null], ["SR 02", "SR", null], ["SR 03", "SR", null], ["SR 04", "SR", null],
			["SSR 01", "SSR", null], ["SSR 02", "SSR", null], ["SSR 03", "SSR", null], ["SSR 04", "SSR", null],
			["UR 01", "UR", null], ["UR 02", "UR", null], ["UR 03", "UR", null], ["UR 04", "UR", null], ["UR 05", "UR", null], ["UR 06", "UR", null],
			["ชุดปกติ Beta AMI","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ Xonebu X'thulhu","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ Mild-R","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ Kumoku Tsururu","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ Debirun","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ T-Reina Ashyra","SSR", "World-End ชุดปกติ"],
			["ชุดปกติ Mycara Melony","SSR", "Mystic ชุดปกติ"],
			["ชุดปกติ Cerafine Mikael","SSR", "Mystic ชุดปกติ"],
			["ชุดปกติ Keressa Zoulfia","SSR", "Mystic ชุดปกติ"],
			["ชุดปกติ Ardalita Lilibelle","SSR", "Mystic ชุดปกติ"],
			["ชุดปกติ Atlanteia Sireen","SSR", "Mystic ชุดปกติ"],
			["ชุดปกติ Nocturnaz Naar","SSR", "Mystic ชุดปกติ"],
			["ชุดนอน Beta AMI","SSR", "World-End ชุดนอน"],
			["ชุดนอน Xonebu X'thulhu","SSR", "World-End ชุดนอน"],
			["ชุดนอน Mild-R","SSR", "World-End ชุดนอน"],
			["ชุดนอน Kumoku Tsururu","SSR", "World-End ชุดนอน"],
			["ชุดนอน Debirun","SSR", "World-End ชุดนอน"],
			["ชุดนอน T-Reina Ashyra","SSR", "World-End ชุดนอน"],
	])

	# ตู้ถาวร มีโอกาสออกทุกตู้
	# ตู้ลิมิต ออกได้เฉพาะตู้นั้นๆ
	mutiple_insert("INSERT INTO Banner_Type (Name) VALUES (?);", [
			["Limited"],
			["Permanent"],
	])

	insert_banner([
		["World-End", "Limited"],
		["Permanent", "Permanent"],
		["Mystic", "Limited"],
		["Rate-Up Beta AMI", "Limited"],
		["Rate-Up Xonebu X'thulhu", "Limited"],
		["Rate-Up Mild-R", "Limited"],
		["Rate-Up Kumoku Tsururu", "Limited"],
		["Rate-Up Debirun", "Limited"],
		["Rate-Up T-Reina Ashyra", "Limited"],
		["NightDress World-End", "Limited"],
	])

	# จำพวก ตู้ชุดต่างๆ

	# ตู้ปกติ
	# ชื่อbanner, ชื่อตู้ปกติ, ชื่อตัวละครที่เพิ่มเรท, เพิ่มเรทกี่เท่า
	# ถ้าไม่มี "ชื่อตู้ปกติ" จะเป็น อาวุธ หรือ แฟนคลับ หรือ UR ที่มีโอกาศออกในทุกๆตู้
	# ถ้าไม่มี "ชื่อตัวละครที่เพิ่มเรท" ทุกตัวจะมีโอกาสเท่ากัน
	insert_banner_rate_up("Permanent", "", "", 1.00)
	insert_banner_rate_up("World-End", "World-End ชุดปกติ", "", 1.00)
	insert_banner_rate_up("Rate-Up Beta AMI", "World-End ชุดปกติ", "ชุดปกติ Beta AMI", 2.00)
	insert_banner_rate_up("Rate-Up Xonebu X'thulhu", "World-End ชุดปกติ", "ชุดปกติ Xonebu X'thulhu", 2.00)
	insert_banner_rate_up("Rate-Up Mild-R", "World-End ชุดปกติ", "ชุดปกติ Mild-R", 2.00)
	insert_banner_rate_up("Rate-Up Kumoku Tsururu", "World-End ชุดปกติ", "ชุดปกติ Kumoku Tsururu", 2.00)
	insert_banner_rate_up("Rate-Up Debirun", "World-End ชุดปกติ", "ชุดปกติ Debirun", 2.00)
	insert_banner_rate_up("Rate-Up T-Reina Ashyra", "World-End ชุดปกติ", "ชุดปกติ T-Reina Ashyra", 2.00)

	insert_banner_rate_up("NightDress World-End", "World-End ชุดนอน", "", 1.00)
	print("Insert data completed.")


func insert_character(data: Array):
	var query = "INSERT INTO Characters (Name, Tier_ID, Characters_Type_ID) VALUES (?, ?, ?);"
	for d in data:
		var tier_id = -1
		if db.query_with_bindings("SELECT ID FROM Characters_Tier WHERE Name = ? LIMIT 1;", [d[1]]):
			var results_tmp = db.query_result
			if results_tmp.size() > 0:
				tier_id =  int(results_tmp[0].get("ID", -1))

		var char_type_id = null
		if d[2] != null and db.query_with_bindings("SELECT ID FROM Characters_Type WHERE Name = ? LIMIT 1;", [d[2]]):
			var results_tmp = db.query_result
			if results_tmp.size() > 0:
				char_type_id =  int(results_tmp[0].get("ID", -1))
		
		if tier_id == -1 or char_type_id == -1:
			print("ไม่เจอ character_type หรือ character_target")
			return

		db.query_with_bindings(query, [d[0], tier_id, char_type_id])

func insert_banner(data: Array):
	var query = "INSERT INTO Banner (Name, Banner_Type_ID) VALUES (?, ?);"
	for d in data:
		var banner_type_id = -1
		if db.query_with_bindings("SELECT ID FROM Banner_Type WHERE Name = ? LIMIT 1;", [d[1]]):
			var results_tmp = db.query_result
			if results_tmp.size() > 0:
				banner_type_id =  int(results_tmp[0].get("ID", -1))
		if banner_type_id == -1:
			print("ไม่เจอ banner_type")
			return
		db.query_with_bindings(query, [d[0], banner_type_id])

func insert_banner_rate_up(banner_name: String, character_type: String, character_target: String, probability: float):
	var banner_query = "SELECT ID FROM Banner WHERE Name = ? LIMIT 1;"
	var BANNER_ID = 0
	if db.query_with_bindings(banner_query, [banner_name]):
		var results_tmp = db.query_result
		if results_tmp.size() > 0:
			BANNER_ID =  int(results_tmp[0].get("ID", -1))

	var char_query = "SELECT ID FROM Characters WHERE Name = ? LIMIT 1;"
	var TARGET_ID = 0
	if character_target != "" and  db.query_with_bindings(char_query, [character_target]):
		var results_tmp = db.query_result
		if results_tmp.size() > 0:
			TARGET_ID = int(results_tmp[0].get("ID", -1))

	if TARGET_ID == -1 or BANNER_ID == -1:
		print("ไม่เจอ character_type หรือ character_target")
		return

	var query = "
		SELECT c.ID, c.Name FROM Characters c 
		INNER JOIN Characters_Type ct on ct.ID = c.Characters_Type_ID
		WHERE ct.Name = ?;
	"
	
	var param = [character_type]
	if character_type == "":
		query = "
			SELECT c.ID, c.Name FROM Characters c 
			LEFT JOIN Characters_Type ct on ct.ID = c.Characters_Type_ID
			WHERE ct.Name IS NULL;
		"
		param = []

		
	if db.query_with_bindings(query, param):
		var results_tmp = db.query_result
		for result in results_tmp:
			var C_ID = int(result.get("ID"))
			var rate = 1.00
			if C_ID == TARGET_ID:
				rate = probability

			# print("Characters: ", result.get("Name"))
			# print("Banner Name: ", banner_name)
			# print("Probability: ", rate)

			query = "
				INSERT INTO banner_rate_up (Charcter_ID, Banner_ID, Probability)
				VALUES(?, ?, ?);
			"
			db.query_with_bindings(query, [C_ID, BANNER_ID, rate])
	else :
		print("ไม่เจอ character_type")

func mutiple_insert(insert_query: String, data: Array):
	# ใช้ query_with_bindings เพื่อ insert ข้อมูลหลายแถว
	for row in data:
		db.query_with_bindings(insert_query, row)
	# print(insert_query, " inserted ", i, " rows.")

# ฟังก์ชันเพื่อเพิ่มผู้เล่น
func add_player(player_name: String, gem: int, salt: int):
	var ID = -1
	var query = "INSERT INTO Players (Name, Gem, Salt) VALUES (?, ?, ?);"
	if db.query_with_bindings(query, [player_name, gem, salt]):
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
			return results[0] # ส่งคืน Dictionary ที่มีข้อมูลในแถวแรก
	return {} # ส่งคืน Dictionary ว่าง ถ้าไม่มีข้อมูลหรือมีข้อผิดพลาด

# ฟังก์ชันดึงค่าจาก player
func get_data_player(player_id: int) -> Dictionary:
	var query = "SELECT * FROM Players WHERE ID = ?;"
	if db.query_with_bindings(query, [player_id]):
		var results = db.query_result
		if results.size() > 0:
			return results[0] # ส่งคืน Dictionary ที่มีข้อมูลของผู้เล่นตาม ID ที่กำหนด
	return {} # ส่งคืน Dictionary ว่าง ถ้าไม่มีข้อมูลสำหรับ ID ที่กำหนดหรือมีข้อผิดพลาด

# ฟังก์ชันดึงค่า gem จาก player
func get_gem(player_id: int) -> int:
	var query = "SELECT Gem FROM Players WHERE ID = ?;"
	# ดำเนินการ query และตรวจสอบผลลัพธ์
	if db.query_with_bindings(query, [player_id]):
		var results = db.query_result
		if results.size() > 0:
			var gem_value = results[0].get("Gem", 0) # ใช้ get() เพื่อป้องกันข้อผิดพลาดถ้าคีย์ไม่เจอ
			return int(gem_value)
	return 0 # ส่งคืน 0 ถ้าไม่มีข้อมูลสำหรับ ID ที่กำหนดหรือมีข้อผิดพลาด

# ฟังก์ชันอัพเดตค่า gem ของ player
func update_gem(player_id: int, new_gem_value: int, new_salt: int):
	# สร้าง query สำหรับการอัปเดตค่า Gem
	var query = "UPDATE Players SET Gem = ?, Salt = Salt + ? WHERE ID = ?;"

	# อัปเดตค่า Gem ของผู้เล่นตาม player_id ที่ระบุ
	if db.query_with_bindings(query, [new_gem_value, new_salt, player_id]):
		print("Updated Gem complete")
	else:
		print("Updated Gem Failed")

func get_players_detail(player_id: int, banner_name: String, loop: int = 1) -> Dictionary:
	var query = "
		SELECT b.Name as banner_name, pgd.IsGuaranteed, pgd.NumberRoll, p.Salt, b.Banner_Type_ID
		FROM Players_Gacha_Detail pgd
			INNER JOIN Players p ON pgd.Players_ID = p.ID
			INNER JOIN Banner b ON pgd.Banner_Type_ID = b.Banner_Type_ID
		WHERE p.ID = ? AND b.Name = ?;
	"
	
	# ดำเนินการ query และตรวจสอบผลลัพธ์
	if db.query_with_bindings(query, [player_id, banner_name]):
		var result = db.query_result
		if result.size() > 0:
			var data = {
				"BannerName": result[0]["banner_name"],
				"IsGuaranteed": result[0]["IsGuaranteed"],
				"NumberRoll": result[0]["NumberRoll"],
				"Salt": result[0]["Salt"],
				"Banner_Type_ID": result[0]["Banner_Type_ID"]
			}
			return data
		else:
			loop = insert_players_detail(player_id, banner_name, loop)
			if loop == -1 or loop > 3:
				return {}
			return get_players_detail(player_id, banner_name, loop)
		
	return {}

func list_banner_type() -> Array:
	var query = "SELECT ID, Name FROM Banner_Type;"
	var results = []
	if db.query(query):
		var tmp = db.query_result
		for result in tmp:
			var data = {
				"ID": result["ID"],
				"Name": result["Name"]
			}
			results.append(data)

	return results

func insert_player_log(data: Array):
	var query = "
		INSERT INTO Players_Gacha_Log (Players_ID, Character_ID, Banner_Type_ID)
		VALUES (?, ?, ?);
	"
	for i in data:
		db.query_with_bindings(query, [i["Players_ID"], i["Character_ID"], i["Banner_Type_ID"]])
	
func update_Players_detail(data: Dictionary, player_id: int):
	var query = "
		UPDATE Players_Gacha_Detail SET IsGuaranteed = ?, NumberRoll = ? WHERE Players_ID = ? AND Banner_Type_ID = ?;
	"
	db.query_with_bindings(query, [data["IsGuaranteed"], data["NumberRoll"], player_id, data["Banner_Type_ID"]])

func get_banner_type(banner_name: String) -> Dictionary:
	var query = "SELECT ID FROM Banner_Type WHERE Name = ?;"
	if db.query_with_bindings(query, [banner_name]):
		var results = db.query_result
		if results.size() > 0:
			return results[0] # ส่งคืน Dictionary ที่มีข้อมูลของผู้เล่นตาม ID ที่กำหนด
	return {}

func insert_players_detail(player_id: int, banner_name: String, loop: int) -> int:
	var banner_type_id = -1

	var query = "SELECT Banner_Type_ID FROM Banner WHERE Name = ?;"
	if db.query_with_bindings(query, [banner_name]):
		var results = db.query_result
		if results.size() > 0:
			banner_type_id = results[0].get("Banner_Type_ID", -1)

	if banner_type_id == -1:
		print("ไม่เจอ banner_type_id")
		return -1

	query = """
		INSERT INTO Players_Gacha_Detail
			(Banner_Type_ID, Players_ID, IsGuaranteed, NumberRoll)
		VALUES (?, ?, 0, 0)
		"""
	db.query_with_bindings(query, [banner_type_id, player_id])
	return loop+1

func get_rate_item() -> Dictionary:
	var query = "SELECT Name, Rate FROM Characters_Tier"
	var data = {}
	var total_probability = 0.0

	if db.query(query):
		var tmp = db.query_result
		for result in tmp:
			var key_name = result["Name"]  # Name
			var rate = float(result["Rate"])  # Rate
			data[key_name] = rate
			total_probability += rate  

	var normalized_data = {}
	for key in data.keys():
		normalized_data[key] = float("%0.5f" % (data[key] / total_probability))

	return normalized_data

func list_banner() -> Array:
	var query = "SELECT ID, Name, Banner_Type_ID FROM Banner WHERE IsEnable = 1;"
	var results = []
	if db.query(query):
		var tmp = db.query_result
		for result in tmp:
			var data = {
				"ID": result["ID"],
				"Name": result["Name"],
				"Banner_Type_ID": result["Banner_Type_ID"]
			}
			results.append(data)
	return results

func get_gacha_item(tier_name: Array=["N", "R", "SR", "UR"], banner_name: String = "Permanent") -> Array:
	var where = " AND tier.Name in "
	if "SSR" in tier_name:
		where += """("SSR");"""
	else :
		where += """("N", "R", "SR", "UR");"""
	var query = """
		SELECT ch.ID as Character_ID, ch.Name, tier.Name as Tier_Name, 
			b.Name as Banner_Name, bt.ID as Banner_Type_ID, 
			bt.Name as BannerType_Name, tier.Salt, bru.Probability as Probability
		FROM Characters as ch
			INNER JOIN Characters_Tier tier ON ch.Tier_ID = tier.id
			INNER JOIN Banner_Rate_Up bru on bru.charcter_id = ch.id
			INNER JOIN Banner b on b.ID = bru.Banner_ID
			INNER JOIN banner_type bt on bt.ID = b.banner_type_id 
		WHERE b.Name in ("Permanent", ?)
	"""+where

	var results = []
	if db.query_with_bindings(query, [banner_name]):
		var tmp = db.query_result
		for result in tmp:
			var data = {
				"Character_ID": result["Character_ID"],
				"Name": result["Name"],
				"Tier_Name": result["Tier_Name"],
				"Banner_Name": result["Banner_Name"],
				"Banner_Type_ID": result["Banner_Type_ID"],	
				"BannerType_Name": result["BannerType_Name"],
				"Salt": result["Salt"],
				"Probability": result["Probability"]
			}
			results.append(data)
	else:
		print("query failed")
	return results

func get_banner_by_type(banner_type_id: int) -> Array:
	var query = "SELECT ID, Name FROM Banner WHERE Banner_Type_ID = ?;"
	var results = []
	if db.query_with_bindings(query, [banner_type_id]):
		var tmp = db.query_result
		for result in tmp:
			var data = {
				"ID": result["ID"],
				"Name": result["Name"]
			}
			results.append(data)
	return results
