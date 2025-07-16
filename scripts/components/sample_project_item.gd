class_name SampleProjectItem
extends HBoxContainer

signal preview_pressed(project_path)
signal delete_pressed(project_path)

# Variables que el script padre (LoadProjectLayer) configurará.
@onready var project_label: Label = %ProjectLabel
@onready var preview_button: Button = %PreviewButton
@onready var delete_button: Button = %DeleteButton

# Ruta completa al archivo .prj que este item representa.
var project_path: String

func _ready():
	# Conectamos las señales de AMBOS botones a sus respectivas funciones.
	preview_button.pressed.connect(_on_preview_button_pressed)
	delete_button.pressed.connect(_on_delete_button_pressed)

func _on_preview_button_pressed():
	# Cuando se presiona el botón de previsualizar/cargar.
	preview_pressed.emit(project_path)

func _on_delete_button_pressed():
	# Cuando se presiona el botón de borrar.
	delete_pressed.emit(project_path)
	
	# Opcional pero recomendado: una vez que se emite la señal de borrar,
	# el item puede eliminarse a sí mismo de la escena.
	queue_free()
