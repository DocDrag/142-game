extends Node2D

@onready var gem_label: Label = $gem_label

func format_commas(number: int) -> String:
	var num_str := str(number)
	var result := ""
	var count := 0
	
	for i in range(num_str.length() - 1, -1, -1):
		result = num_str[i] + result
		count += 1
		if count % 3 == 0 and i != 0:
			result = "," + result
			
	return result

func update_gem(gem: int):
	gem_label.text = format_commas(gem)
