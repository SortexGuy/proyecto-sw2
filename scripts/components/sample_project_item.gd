class_name SampleProjectItem
extends HBoxContainer

# Las señales que emite este componente no cambian. ¡Perfecto!
signal preview_pressed(project_path)
signal delete_pressed(project_path)

# Variables que el script padre (LoadProjectLayer) configurará.
@onready var project_label: Label = %ProjectLabel
# Cambiamos la referencia al nuevo botón de carga.
@onready var load_button: Button = %LoadButton
@onready var delete_button: Button = %DeleteButton

# Ruta completa al archivo .prj que este item representa.
var project_path: String

func _ready():
	# Conectamos la señal del nuevo botón de carga.
	load_button.pressed.connect(_on_load_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

# Un setter es una buena práctica para configurar el estado de un nodo desde fuera.
func set_project_path(path: String):
	project_path = path

# Renombramos la función para que coincida con el nuevo botón.
func _on_load_button_pressed():
	# La lógica aquí es idéntica a la anterior.
	if project_path.is_empty():
		printerr("Project Path Empty")
		return
	preview_pressed.emit(project_path)

func _on_delete_button_pressed():
	if project_path.is_empty(): return
	# El nodo ya no se autodestruye. Solo notifica.
	delete_pressed.emit(project_path)
