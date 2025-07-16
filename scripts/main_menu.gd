class_name MainMenu
extends Node

@export_file("*.tscn", "*.scn") var main_scene: String = "res://scenes/main_scene.tscn"
@onready var main_window_layer := %MainWindowLayer
@onready var mw_load_project_layer := %MW_LoadProjectLayer

func _ready() -> void:
	main_window_layer.create_project_button.pressed.connect(on_mwl_create_project_button_pressed)
	main_window_layer.load_project_button.pressed.connect(on_mwl_load_project_button_pressed)
	main_window_layer.close_button.pressed.connect(on_mwl_close_button_pressed)
	mw_load_project_layer.back_button.pressed.connect(on_lpl_back_button_pressed)
	
	# Conectamos las nuevas señales del menú de carga a nuestras nuevas funciones.
	mw_load_project_layer.project_selected_for_load.connect(_on_load_project_requested)
	mw_load_project_layer.project_selected_for_delete.connect(_on_delete_project_requested)


# --- Tus funciones existentes (sin cambios) ---
func on_lpl_back_button_pressed() -> void:
	mw_load_project_layer.offset.x = 1080.0
	main_window_layer.offset.x = 0.0

func on_mwl_create_project_button_pressed() -> void:
	get_tree().change_scene_to_file(main_scene)

func on_mwl_load_project_button_pressed() -> void:
	mw_load_project_layer.load_project_list()
	mw_load_project_layer.offset.x = 0.0
	main_window_layer.offset.x = -1080.0

func on_mwl_close_button_pressed() -> void:
	get_tree().quit()


# --- NUEVAS FUNCIONES AÑADIDAS AL FINAL DEL SCRIPT ---

func _on_load_project_requested(path: String):
	"""Carga los datos del proyecto y cambia a la escena principal."""
	print("MainMenu: Recibida orden de cargar el proyecto: %s" % path)

	# Usa un singleton (Autoload) para pasar los datos.
	# Asegúrate de haber creado el script project_loader.gd y haberlo añadido a Autoload.
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var json = JSON.new()
		json.parse(file.get_as_text())
		ProjectLoader.set_data_to_load(json.data)
		get_tree().change_scene_to_file(main_scene)
	else:
		push_error("No se pudo abrir el archivo de proyecto: " + path)


func _on_delete_project_requested(path: String):
	"""Borra el archivo de proyecto del disco."""
	print("MainMenu: Recibida orden de borrar el proyecto: %s" % path)
	
	var err = DirAccess.remove_absolute(path)
	if err == OK:
		print("Archivo de proyecto borrado con éxito.")
	else:
		push_error("No se pudo borrar el archivo de proyecto.")
