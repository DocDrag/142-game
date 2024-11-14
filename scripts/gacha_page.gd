extends Control

var banner_gacha_name: String
const GACHA_DIAMONDS_USED: int = 0
const GUARANTE_RATE: int = 71
# การันตรีหน้าตู้หรือไม่ ยกเว้นตู้ถาวร
const GUARANTE_PICKUP = true

func _ready():
	var options: Array
	# คำนวนขนาดของรูป โดยอ้างอิงจากขนาดรูปเดิม
	var per = 50
	var button_size = Vector2($scrollable_menu.percent(1280, per), $scrollable_menu.percent(600, per))
	options.append($scrollable_menu.new_option("ตู้ถาวร", "res://Assets/Picture/gacha/banner/banner_All.png"))
	options.append($scrollable_menu.new_option("World-End", "res://Assets/Picture/gacha/banner/banner_All.png"))
	options.append($scrollable_menu.new_option("Rate-Up Beta AMI", "res://Assets/Picture/gacha/banner/banner_AMI.png"))
	options.append($scrollable_menu.new_option("Rate-Up T-Reina Ashyra", "res://Assets/Picture/gacha/banner/banner_Ashyra.png"))
	options.append($scrollable_menu.new_option("Rate-Up Debirun", "res://Assets/Picture/gacha/banner/banner_Debirun.png"))
	options.append($scrollable_menu.new_option("Rate-Up Mild-R", "res://Assets/Picture/gacha/banner/banner_Mild-R.png"))
	options.append($scrollable_menu.new_option("Rate-Up Kumoku Tsururu", "res://Assets/Picture/gacha/banner/banner_Tsururu.png"))
	options.append($scrollable_menu.new_option("Rate-Up Xonebu X'thulhu", "res://Assets/Picture/gacha/banner/banner_Xonebu.png"))
	$scrollable_menu.ScrollableMenu(options, button_size)

	$gacha_display.text = ""
	$count_gacha.text = ""
	banner_gacha_name = "World-End"
	$banner_name.text = banner_gacha_name
	
	
func _process(_delta):
	if not $SQLiteManager.is_not_system_in_database():
		var NowUseID = $SQLiteManager.get_data_system()["NowUseID"]
		var Gem = $SQLiteManager.get_data_player(NowUseID)["Gem"]
		$"Gem Frame".update_gem(Gem)
		
		
func _on_btn_back_pressed():
	# เปลี่ยนฉากไปยังฉาก main_scene.tscn ที่อยู่ในโฟลเดอร์ Scene
	get_tree().change_scene_to_file("res://Scenes/main_scene.tscn")


func _input(event):
	var button_use = $scrollable_menu.handle_event(event)
	var player_id = int($SQLiteManager.get_data_system()["NowUseID"])
	if button_use != null:
		$gacha_display.text = ""
		banner_gacha_name = button_use
		$banner_name.text = banner_gacha_name

		var player_detail = $SQLiteManager.get_players_detail(player_id, banner_gacha_name, 1)
		if player_detail == {}:
			$count_gacha.text = "ไม่พบข้อมูล Player"
			return
		update_count_gacha(player_detail)

func update_count_gacha(player_detail: Dictionary):
	var guaranteText = "ไม่มีการันตรี" if player_detail["IsGuaranteed"] == 0 else "มีการันตรี"
	$count_gacha.text = str("จำนวน Roll : ", player_detail["NumberRoll"], ",  ", guaranteText)

func _on_btn_1_roll_pressed():
	# print("\n\n",banner_gacha_name)
	var result = multiple_pulls(banner_gacha_name, 1)
	var item = result["Result"]
	var err = result["Error"]
	if err != "":
		print(err)
		return
	var text = ""
	for i in range(len(item)):
		# print(item[i]["Name"], item[i]["Tier_Name"], item[i]["Salt"])
		text += item[i]["Name"]
		if i % 2 == 1:
			text += "\n"
		elif i != len(item) - 1:
			text += ",  "
	$gacha_display.text = text

func _on_btn_10_roll_pressed():
	# print("\n\n",banner_gacha_name)
	var result = multiple_pulls(banner_gacha_name, 10)
	var item = result["Result"]
	var err = result["Error"]
	if err != "":
		print(err)
		return
		
	var text = ""
	for i in range(len(item)):
		# print(item[i]["Name"] + " " + item[i]["Tier_Name"])
		text += item[i]["Name"]
		if i % 2 == 1:
			text += "\n"
		elif i != len(item) - 1:
			text += ",  "
	$gacha_display.text = text

func check_gem(player_id: int, num_pulls: int) -> Array:
	var gem = $SQLiteManager.get_gem(player_id)
	var remaining_diamonds = int(gem - (num_pulls * GACHA_DIAMONDS_USED))
	if remaining_diamonds < 0:
		return [false, 0]
	return [true, remaining_diamonds]

func multiple_pulls(banner_name: String, num_pulls: int) -> Dictionary:
	var output = {
		"Result": [],
		"Error": "",
	}
	
	# ดึงข้อมูลผู้เล่นที่เล่นอยู่ใน ปัจจุบัน
	var NowUseID = int($SQLiteManager.get_data_system()["NowUseID"])
	var player_detail = $SQLiteManager.get_players_detail(NowUseID, banner_name, 1)
	if player_detail == {}:
		output["Error"] = "Player not found"
		return output
	
	# เช็คว่าจำนวนเพชรเพียงพอหรือไม่
	var result = check_gem(NowUseID, num_pulls)
	if not result[0]:
		output["Error"] = "Not enough diamonds"
		return output
	var remaining_diamonds = result[1]
	
	result = []
	var player_log = []
	var sum_salt = 0
	var gachaRate = $SQLiteManager.get_rate_item()
	
	# เพิ่มโอกาสได้ UR ในตู้ถาวร 10 เท่า
	if banner_name == "ตู้ถาวร":
		gachaRate["UR"] *= 10

	# สุ่ม num_pulls รอบ
	for i in range(num_pulls):
		var item_list = gachaRate.keys()
		var probabilities = normalize_Probabilities(gachaRate.values())
		var tier = random_weighted_choice(item_list, probabilities)

		var tmp = gacha_item(tier, banner_name, player_detail, NowUseID)
		result.append(tmp[0])
		player_log.append(tmp[1])
		player_detail = tmp[2]
		sum_salt += tmp[0]["Salt"]

	# อัพเดตจำนวนเพชร
	$SQLiteManager.update_gem(NowUseID, remaining_diamonds, sum_salt)
	
	# เพิ่ม log
	$SQLiteManager.insert_player_log(player_log)

	# อัพเดตข้อมูลผู้เล่น
	$SQLiteManager.update_Players_detail(player_detail, NowUseID)

	# อัพเดทหน้าจอว่ามี การันตรีไหม และจำนวน Roll
	update_count_gacha(player_detail)

	output["Result"] = result
	return output

func gacha_item(tier: String, bannerName: String, player_detail: Dictionary, player_id: int) -> Array:
	var bannerTypeID = player_detail["Banner_Type_ID"]
	var gachaItems = []
	player_detail["NumberRoll"] += 1

	# ถ้าเป็น SSR หรือ จำนวนโรลถึง GUARANTE_RATE
	if tier == "SSR" or player_detail["NumberRoll"] > GUARANTE_RATE:
		# ดึงข้อมูลตัวละคร SSR ใน Banner ที่สุ่ม
		var tmp = get_SSR_Item(player_detail, bannerName)
		gachaItems = tmp[0]
		player_detail = tmp[1]
		tier = "SSR"
	else:
		# ดึงข้อมูลตัวละคร ใน Banner ที่สุ่มตามปกติ
		gachaItems = $SQLiteManager.get_gacha_item()

	# Filter เฉพาะ tier ที่สุ่มได้
	var new_gachaItems = []
	var probabilities = []
	for i in range(len(gachaItems)):
		if gachaItems[i]["Tier_Name"] == tier:
			new_gachaItems.append(gachaItems[i])
			probabilities.append(gachaItems[i]["Probability"])

	# normalize Probabilities
	probabilities = normalize_Probabilities(probabilities)
	var item = random_weighted_choice(new_gachaItems, probabilities)

	# ถ้าหากเปิด GUARANTE_PICKUP และตัวละครที่สุ่มได้อยู่ในตู้เดียวกัน
	if GUARANTE_PICKUP and item["Banner_Name"] == bannerName:
		# ดึงข้อมูลตัวละครหน้าตู้ที่เพิ่ม Rate Up ซึ่งซัพพอร์ตัวละครหลายตัว
		var banner_rate_up = $SQLiteManager.get_garuantee_item(bannerName)
		player_detail["IsGuaranteed"] = 1
		for i in range(len(banner_rate_up)):
			# แต่ถ้าตัวที่สุ่มได้คือตัวละครที่เพิ่ม Rate Up จะทำให้ IsGuaranteed เป็น 0
			if banner_rate_up[i]["Character_ID"] == item["Character_ID"]:
				player_detail["IsGuaranteed"] = 0

	var result = {
		"Character_ID": item["Character_ID"],
		"Name": item["Name"],
		"Tier_Name": item["Tier_Name"],
		"Salt": item["Salt"],
	}

	var data_log = {
		"Players_ID": player_id,
		"Character_ID": item["Character_ID"],
		"Banner_Type_ID": bannerTypeID,
	}
	return [result, data_log, player_detail]

func get_SSR_Item(player_detail: Dictionary, banner_name: String) -> Array:
	var bannerItem = $SQLiteManager.get_gacha_item(["SSR"], banner_name)
	var banner_type_id = player_detail["Banner_Type_ID"]
	var banner_type_item = $SQLiteManager.list_banner_type()

	# ถ้ามีการันตรี SSR
	if int(player_detail["IsGuaranteed"]) == 1:
		player_detail["IsGuaranteed"] = 0
		# การันตรีหน้าตู้
		if GUARANTE_PICKUP:
			var banner_rate_up = $SQLiteManager.get_garuantee_item(banner_name)
			bannerItem = banner_rate_up
	else:
		# สุ่มว่า Banner Type ที่ได้เป็น ตู้ Limited หรือ ตู้ Permanent
		var weights = []
		for i in range(len(banner_type_item)):
			weights.append(1)
		var randomBanner_Type = random_weighted_choice(banner_type_item, weights)
		if randomBanner_Type["Name"] == "ตู้ถาวร":
			player_detail["IsGuaranteed"] = 1
		else: 
			# สุ่มได้ Limited
			player_detail["IsGuaranteed"] = 0
			# ถ้าไม่ได้เป็นตัวละครหน้าตู้ จะทำให้ IsGuaranteed = 1
			if GUARANTE_PICKUP:
				print("GUARANTE_PICKUP 2")
				player_detail["IsGuaranteed"] = 1
		# ถ้า Banner Name ไม่ใช่ ตู้ถาวร จะอัทเดท Banner Type ID ที่จะได้ Filter
		if banner_name != "ตู้ถาวร":
			banner_type_id = randomBanner_Type["ID"]
	
	# Reset NumberRoll
	player_detail["NumberRoll"] = 0
	
	# Filter
	var new_bannerItem = []
	for i in range(len(bannerItem)):
		if bannerItem[i]["Banner_Type_ID"] == banner_type_id:
			new_bannerItem.append(bannerItem[i])

	return [new_bannerItem, player_detail]


func random_weighted_choice(items: Array, weights: Array) -> Variant:
	if items.size() != weights.size():
		push_error("Items and weights arrays must have the same size.")
		return null
	
	# Calculate the total weight
	var total_weight = 0.0
	for weight in weights:
		total_weight += weight
	
	# Generate a random number within the range of total_weight
	var random_value = randi_range(0, total_weight * 1000) / 1000.0
	
	# Select an item based on the random number
	for i in range(items.size()):
		random_value -= weights[i]
		if random_value <= 0:
			# print("Selected item:", items[i], " with weight:", weights[i])
			return items[i]
	
	print("Selected item:", items, " with weight:", weights)

	return items[-1] # Fallback (should rarely happen if weights are valid)

func normalize_Probabilities(probability: Array) -> Array:
	var total_probability = 0.0
	for item in probability:
		total_probability += item

	for i in range(len(probability)):
		probability[i] = float("%0.5f" % (probability[i] / total_probability))
	
	return probability
