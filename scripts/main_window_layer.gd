extends CanvasLayer

@onready var proyecto = get_parent().get_node("../World/WorldLayer")
@onready var cargar = get_parent().get_node("../Interfaces/MW_LoadProjectLayer")

#Para iniciar el proyecto
func _on_crear_proyecto_pressed():
	proyecto.visible = true
	self.visible = false

#Para cargar un proyecto
func _on_cargar_proyecto_pressed():
	cargar.visible = true
	self.visible = false

#Para salir
func _on_cerrar_pressed():
	get_tree().quit()
