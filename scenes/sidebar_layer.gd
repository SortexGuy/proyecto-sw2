extends CanvasLayer

@onready var world = get_parent().get_node("../World/WorldLayer")
@onready var atras = get_parent().get_node("MainWindowLayer")
@onready var store = get_parent().get_node("Side_StoreLayer")
@onready var escalas = get_parent().get_node("Side_DimensionsLayer")
@onready var importar = get_parent().get_node("Side_ImportLayer")
@onready var guardar = get_parent().get_node("Side_SaveLayer")

#Para quitar la visibilidad del sidebar
func _on_button_pressed():
	self.visible = false
	
#Botones de en medio
func _on_boton_modelos_pressed():
	store.visible = true
	
func _on_modificar_escalas_pressed():
	escalas.visible = true

func _on_importar_modelos_pressed():
	importar.visible = true

func _on_guardar_p_pressed():
	guardar.visible = true

#Para salir del proyecto y pasar al menú principal
func _on_boton_salir_pressed():
	atras.visible = true
	self.visible = false
	
