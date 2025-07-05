class_name MainMenu
extends Node

#@export var main_scene: PackedScene
@onready var main_window_layer: MainWindowLayer = %MainWindowLayer
@onready var mw_load_project_layer: LoadProjectLayer = %MW_LoadProjectLayer

func _ready() -> void:
	main_window_layer.create_project_button.pressed.connect(on_mwl_create_project_button_pressed)
	main_window_layer.load_project_button.pressed.connect(on_mwl_load_project_button_pressed)
	main_window_layer.close_button.pressed.connect(on_mwl_close_button_pressed)
	mw_load_project_layer.back_button.pressed.connect(on_lpl_back_button_pressed)

func on_lpl_back_button_pressed() -> void:
	mw_load_project_layer.offset.x = 1080.0
	main_window_layer.offset.x = 0.0
	pass

func on_mwl_create_project_button_pressed() -> void:
	#get_tree().change_scene_to_packed(main_scene)
	pass

func on_mwl_load_project_button_pressed() -> void:
	mw_load_project_layer.load_project_list()
	mw_load_project_layer.offset.x = 0.0
	main_window_layer.offset.x = -1080.0
	pass

func on_mwl_close_button_pressed() -> void:
	get_tree().quit()
	pass
