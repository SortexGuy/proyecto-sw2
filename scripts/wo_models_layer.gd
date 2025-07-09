extends CanvasLayer

# Señal que este panel emitirá al resto del juego cuando un modelo sea finalmente seleccionado.
signal model_selected(url)

# 1. Carga la escena de la plantilla del botón.
const MODEL_BUTTON_SCENE = preload("res://scenes/container/model_button.tscn")
# 2. Define la ruta donde están tus modelos 3D. ¡Asegúrate de que esta ruta es correcta!
const MODELS_PATH = "res://models"

# 3. Referencia al contenedor donde se añadirán los botones.
# Usa la ruta de nodos correcta desde WO_ModelsLayer.
@onready var buttons_container = $PanelContainer2/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/ScrollContainer/ButtonsContainer

func _ready() -> void:
	# Llama a la función para generar los botones cuando la escena esté lista.
	populate_model_list()

func populate_model_list() -> void:
	# Limpia cualquier botón que pudiera existir de antes (útil si se llama a esta función más de una vez).
	for child in buttons_container.get_children():
		child.queue_free()

	# Accede al directorio de modelos.
	var dir = DirAccess.open(MODELS_PATH)
	if dir:
		# Itera sobre todos los archivos del directorio.
		for file_name in dir.get_files():
			# Filtra para que solo procese archivos .glb.
			if file_name.ends_with(".glb"):
				# Crea una nueva instancia de nuestra escena de botón.
				var new_button = MODEL_BUTTON_SCENE.instantiate()
				
				# Construye la ruta completa y el nombre a mostrar.
				var model_path = MODELS_PATH.path_join(file_name)
				var display_name = file_name.get_basename() # "mi_modelo.glb" -> "mi_modelo"
				
				# --- ORDEN CORREGIDO ---
				
				# 1. AÑADE el botón al contenedor PRIMERO para que sus nodos @onready se inicialicen.
				buttons_container.add_child(new_button)
				
				# 2. AHORA llama a la función setup para configurar el botón.
				new_button.setup(model_path, display_name)
				
				# 3. Conecta la señal del nuevo botón a una función en ESTE script.
				new_button.button_was_pressed.connect(_on_any_model_button_pressed)
				
	else:
		# Reporta un error si la carpeta de modelos no se encuentra.
		push_error("No se pudo abrir el directorio de modelos en: " + MODELS_PATH)


# Esta única función manejará el clic de CUALQUIER botón que hayamos creado.
func _on_any_model_button_pressed(url_del_modelo: String) -> void:
	print("Se ha seleccionado un modelo en la capa de UI. URL: ", url_del_modelo)
	
	model_selected.emit(url_del_modelo)
	
	self.visible = false
