extends Node

var data_to_load: Dictionary = {}
func set_data_to_load(data: Dictionary): data_to_load = data
func get_and_clear_data() -> Dictionary:
	var data = data_to_load
	data_to_load = {}
	return data
