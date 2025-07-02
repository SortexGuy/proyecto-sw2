extends CanvasLayer

@onready var Sidebar = get_parent().get_node("SidebarLayer")
@onready var modelos = get_parent().get_node("WO_ModelsLayer")

#Hace aparecer el SidebarLayer
func _on_button_pressed():
	Sidebar.visible = true

#Hace aparecer la ventana de modelos
func _on_button_2_pressed():
	modelos.visible = true
