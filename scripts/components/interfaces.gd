class_name Interfaces
extends Node

@export_file("*.tscn", "*.scn") var main_menu_scene: String = "res://scenes/main_menu.tscn"
@onready var wo_layer: CanvasLayer = %WorldOverlayLayer
@onready var wo_models_layer: CanvasLayer = %WO_ModelsLayer
@onready var sidebar_layer: SidebarLayer = %SidebarLayer
@onready var side_store_layer: CanvasLayer = %Side_StoreLayer
@onready var side_dimensions_layer: CanvasLayer = %Side_DimensionsLayer
@onready var side_import_layer: CanvasLayer = %Side_ImportLayer
@onready var side_save_layer: CanvasLayer = %Side_SaveLayer

@onready var world_layer: CanvasLayer = get_node("../World/WorldLayer")


#Inicializar botones
func _ready():
	sidebar_layer.exit_button.pressed.connect(_on_exit_button_pressed)
	wo_layer.visible = true
	if wo_models_layer and world_layer:
		wo_models_layer.model_selected.connect(world_layer.add_model)
		print("Conexión de señal realizada con éxito: wo_models_layer -> world_layer.add_model")
	else:
		# Añadimos depuración para saber exactamente qué falló
		if not wo_models_layer:
			push_error("Error en Interfaces: No se encontró el nodo wo_models_layer.")
		if not world_layer:
			push_error("Error en Interfaces: No se encontró el nodo world_layer. La ruta '../World/WorldLayer' es incorrecta o el nodo no se llama así.")

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
	pass
