extends CanvasLayer

@onready var atras = get_parent().get_node("../Interfaces/MainWindowLayer")

#Vuelve al menú principal
func _on_button_0_pressed():
	atras.visible = true
	self.visible = false
