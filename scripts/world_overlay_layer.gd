extends CanvasLayer

@onready var Sidebar = get_parent().get_node("SidebarLayer")
@onready var modelos = get_parent().get_node("WO_ModelsLayer")
@onready var sidepanel_button: Button = %SidepanelButton
@onready var add_model_button: Button = %AddModelButton

#Hace aparecer el SidebarLayer
func _on_button_pressed():
	Sidebar.visible = true

#Hace aparecer la ventana de modelos
func _on_button_2_pressed():
	modelos.visible = true
