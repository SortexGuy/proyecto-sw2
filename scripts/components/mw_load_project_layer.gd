class_name LoadProjectLayer
extends CanvasLayer

signal project_selected_for_load(path)
signal project_selected_for_delete(path)

const SAVE_FOLDER = "res://saved_projects/" 

@export_file("*.tscn", "*.scn") var prj_item_sample: String = "res://scenes/components/sample_project_item.tscn"
@onready var back_button: Button = %BackButton
@onready var projects_container: VBoxContainer = %ProjectsContainer

func load_project_list() -> void:
	for c in projects_container.get_children():
		c.queue_free()
	
	var dir = DirAccess.open(SAVE_FOLDER)
	if not dir:
		print("La carpeta de proyectos guardados no existe aún en: ", SAVE_FOLDER)
		return
	
	for file_name in dir.get_files():
		if not file_name.ends_with(".prj"):
			continue
		var prj_item_sample_node = load(prj_item_sample)
		var sample_node = prj_item_sample_node.instantiate()
		
		# 1. Añadimos el nodo al contenedor PRIMERO.
		projects_container.add_child(sample_node)
		
		# 2. Ahora configuramos el nodo, que ya está listo.
		sample_node.project_label.text = file_name.trim_suffix(".prj").capitalize()
		sample_node.project_path = SAVE_FOLDER.path_join(file_name)
		
		# 3. Conectamos sus señales.
		sample_node.preview_pressed.connect(_on_a_project_item_was_selected_for_load)
		sample_node.delete_pressed.connect(_on_a_project_item_was_selected_for_delete)

func _ready() -> void:
	load_project_list()

func _on_a_project_item_was_selected_for_load(path: String):
	project_selected_for_load.emit(path)

func _on_a_project_item_was_selected_for_delete(path: String):
	project_selected_for_delete.emit(path)
