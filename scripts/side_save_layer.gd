extends CanvasLayer

@onready var file_name_edit: LineEdit = %LineEdit 

@onready var interfaces_node: Node = get_node("..") 

const SAVE_PATH = "res://saved_projects"

func _on_button_2_pressed():
	# 1. Obtenemos el nombre del archivo desde el LineEdit.
	var project_name = file_name_edit.text
	
	# 2. Validamos que el nombre no esté vacío.
	if project_name.is_empty():
		# Opcional: Mostrar un mensaje de error al usuario.
		# Por ejemplo, haciendo que el LineEdit se ponga rojo por un momento.
		push_error("El nombre del proyecto no puede estar vacío.")
		return
	
	DirAccess.make_dir_absolute(SAVE_PATH)
	
	# 3. Construimos la ruta completa del archivo.
	# Añadimos la extensión .prj si el usuario no la puso.
	var file_path = SAVE_PATH.path_join(project_name)
	if not file_path.ends_with(".prj"):
		file_path += ".prj"
	
	# 4. Pedimos los datos del proyecto al WorldLayer a través de Interfaces.
	# Obtenemos la referencia a world_layer desde el nodo de interfaces.
	var world_layer = interfaces_node.world_layer
	var data_to_save = world_layer.save_project_data()
	
	# 5. Guardamos los datos en el archivo.
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		# Convertimos el diccionario a un string JSON formateado para que sea legible.
		var json_string = JSON.stringify(data_to_save, "\t")
		file.store_string(json_string)
		print("¡Proyecto guardado con éxito en: ", file_path)
	else:
		push_error("Error: No se pudo guardar el archivo en la ruta: " + file_path)

	# 6. Ocultamos la ventana de guardado.
	self.visible = false
