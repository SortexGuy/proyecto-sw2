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
		
		projects_container.add_child(sample_node)
		
		# NOTA: Tu script original asigna la ruta al nodo hijo.
		# Esto es menos seguro. Es mejor tener un método setter en el hijo.
		# Pero manteniendo tu lógica, el código sigue funcionando.
		sample_node.project_label.text = file_name.trim_suffix(".prj").capitalize()
		sample_node.project_path = SAVE_FOLDER.path_join(file_name) # Asumiendo que SampleProjectItem tiene esta variable.
		
		sample_node.preview_pressed.connect(_on_a_project_item_was_selected_for_load)
		
		# --- CAMBIO 1 ---
		# Usamos .bind() para pasar el nodo que se va a borrar.
		sample_node.delete_pressed.connect(_on_a_project_item_was_selected_for_delete.bind(sample_node))

func _ready() -> void:
	load_project_list()

func _on_a_project_item_was_selected_for_load(path: String):
	project_selected_for_load.emit(path)

# --- CAMBIO 2 ---
# La función ahora acepta el nodo y lo elimina de la escena.
func _on_a_project_item_was_selected_for_delete(path: String, item_node: SampleProjectItem):
	# Le decimos al main_menu que borre el ARCHIVO.
	project_selected_for_delete.emit(path)
	
	# Eliminamos el NODO de la lista visual al instante.
	item_node.queue_free()
