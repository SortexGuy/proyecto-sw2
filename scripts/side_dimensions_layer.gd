extends CanvasLayer
@onready var width_spinbox = $PanelPrincipal2/Margen/VBoxContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/SpinBox
@onready var depth_spinbox = $PanelPrincipal2/Margen/VBoxContainer/PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/SpinBox

signal cambio_dim(width,depth)

#Cierra esta ventana
func _on_button_pressed():
	self.visible = false

#Variables que contienen las nuevas dimensiones
func _on_button_2_pressed() -> void:
	var width = width_spinbox.value
	var depth = depth_spinbox.value
	#cambio_dim -> Cambio de Dimensiones :D
	emit_signal("cambio_dim", width, depth)
