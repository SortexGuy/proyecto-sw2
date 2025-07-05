class_name Interfaces
extends Node

#@export var main_menu_scene: PackedScene
@onready var wo_layer: CanvasLayer = %WorldOverlayLayer
@onready var wo_models_layer: CanvasLayer = %WO_ModelsLayer
@onready var sidebar_layer: SidebarLayer = %SidebarLayer
@onready var side_store_layer: CanvasLayer = %Side_StoreLayer
@onready var side_dimensions_layer: CanvasLayer = %Side_DimensionsLayer
@onready var side_import_layer: CanvasLayer = %Side_ImportLayer
@onready var side_save_layer: CanvasLayer = %Side_SaveLayer

#Inicializar botones
func _ready():
	sidebar_layer.exit_button.pressed.connect(_on_exit_button_pressed)
	wo_layer.visible = true

func _on_exit_button_pressed() -> void:
	#get_tree().change_scene_to_packed(main_menu_scene)
	pass
