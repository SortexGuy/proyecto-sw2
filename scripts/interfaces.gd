class_name Interfaces
extends Node

@onready var wo_layer: CanvasLayer = %WorldOverlayLayer
@onready var wo_models_layer: CanvasLayer = %WO_ModelsLayer
@onready var sidebar_layer: CanvasLayer = %SidebarLayer
@onready var side_store_layer: CanvasLayer = %Side_StoreLayer
@onready var side_dimensions_layer: CanvasLayer = %Side_DimensionsLayer
@onready var side_import_layer: CanvasLayer = %Side_ImportLayer
@onready var side_save_layer: CanvasLayer = %Side_SaveLayer

#Inicializar botones
func _ready():
	wo_layer.visible = true
