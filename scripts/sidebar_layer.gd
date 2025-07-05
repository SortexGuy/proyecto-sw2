class_name SidebarLayer
extends CanvasLayer

@onready var exit_button: Button = %ExitButton
@onready var world = get_parent().get_node("../World/WorldLayer")
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
