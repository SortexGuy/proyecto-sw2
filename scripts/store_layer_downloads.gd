extends CanvasLayer

const API_MODELOS_URL := "http://localhost:3000/models"
const API_GLTF_URL := "http://localhost:3000/models/static/"
const META_LOCAL_PATH := "user://modelos_locales.json"

var modelos = {}
var modelo_en_descarga_id = null

var iD := 0

@onready var http := $HTTPRequest

@onready var label := $PanelPrincipal3/SideVista2MODELOS/VBoxContainer/Label

@onready var container := $PanelPrincipal3/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer
@onready var button: Button = %Button
@onready var back_button: Button = %BackButton2
@onready var note := container.get_node("Note")

func _ready():
	if is_instance_valid(button) and button.get_parent():
		button.visible = false

#recibe el texto para el label y el id desde side_store_layer
func receive_text(text: String, ID: int):
	iD = ID
	print("Texto recibido: ", text,". ID: ", iD)
	label.text = text
	modelos = {}
	print(" Conectando y solicitando modelos...")
	http.request_completed.connect(_on_http_request_completed)
	obtener_modelos()
	note.visible = false
	for child in container.get_children():
		if child.name != "Note":
			child.queue_free()

func obtener_modelos():
	print("Solicitando modelos desde el backend: ", API_MODELOS_URL)
	http.timeout = 5 #Sirve para modificar el tiempo de espera de la conexión
	var err = http.request(API_MODELOS_URL)
	if err != OK:
		print(" Error al solicitar modelos:", err)

func _on_http_request_completed(result, response_code, headers, body):
	print(" Respuesta HTTP recibida. Código:", response_code, " Modelo en descarga:", modelo_en_descarga_id)

	if response_code == 200 and body.size() > 0:
		if modelo_en_descarga_id == null:
			print(" Cargando lista de modelos")
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("data"):
				var lista = parsed["data"]
				for modelo in lista:
					modelo.id = int(modelo.id)
					print(" Modelo recibido:", modelo.name, " ID:", modelo.id," Categoría ", modelo.categories)
					note.text = "En este momento no hay archivos\ndisponibles"
					if modelo.subcategories[0] == iD:
						modelos[modelo.id] = modelo
				buttons(modelos)
		else:
			print(" Descarga de modelo ID:", modelo_en_descarga_id, " completada. Guardando...")
			guardar_archivo_glb(body)
	else:
		print("Error HTTP:", response_code, " Body size:", body.size())
		if modelo_en_descarga_id != null:
			modelo_en_descarga_id = null
		note.text = "No se pudo conectar con el servidor"
		if body.size() == 33:
			note.text = "Modelo inválido o no disponible"
		modelos = {}
		buttons(modelos)
		return

func buttons(modelos):
	if modelos == {}:
		note.visible = true
	else:
		note.visible = false
		for i in modelos:
			var model_data = modelos[i]
			print(i," | ",model_data.name)
			var btn := button.duplicate()
			btn.name = model_data.name
			btn.text = model_data.name
			btn.visible = true
			btn.pressed.connect(_on_button_model_pressed.bind(model_data.id))

			container.add_child(btn)

func _on_button_model_pressed(modelo_id):
	note.visible = false
	print(" Botón presionado. Solicitando modelo ID:", modelo_id)
	modelo_en_descarga_id = int(modelo_id)
	var ruta = "downloads/modelo_" + str(modelo_en_descarga_id) + ".glb"

	if FileAccess.file_exists(ruta):
		print("El modelo ya se encuentra disponible en la aplicación")
		note.text = "El modelo ya se encuentra disponible\nen la aplicación"
		note.visible = true
		modelo_en_descarga_id = null
		return

	var url_descarga = API_GLTF_URL + str(modelo_en_descarga_id)
	print(" Solicitando:", url_descarga)
	var err = http.request(url_descarga)
	if err != OK:
		print(" Error solicitando .glb del modelo:", modelo_en_descarga_id)

#descargar archivo
func guardar_archivo_glb(bytes):
	var carpeta = "downloads"
	var ruta = carpeta + "/modelo_" + str(modelo_en_descarga_id) + ".glb"

	var dir = DirAccess.open("res://")
	if not dir.dir_exists(carpeta):
		var err = dir.make_dir(carpeta)
		if err != OK:
			print("Error al crear la carpeta 'downloads': ", err)
			return

	print("Guardando .glb en: ", ruta)

	var file = FileAccess.open(ruta, FileAccess.WRITE)
	if file:
		file.store_buffer(bytes)
		file.close()
		guardar_metadatos_locales(modelo_en_descarga_id, ruta)
	else:
		print("Error al abrir el archivo para escritura.")

	modelo_en_descarga_id = null

func guardar_metadatos_locales(id, ruta_glb):
	print(" Guardando metadatos para el modelo ID:", id)
	var data := {}

	if FileAccess.file_exists(META_LOCAL_PATH):
		var f = FileAccess.open(META_LOCAL_PATH, FileAccess.READ)
		var contenido = f.get_as_text()
		var parsed = JSON.parse_string(contenido)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
		else:
			print("  El archivo de metadatos está vacío o malformado. Se reiniciará.")
		f.close()

	var modelo = modelos[id]
	data[str(id)] = {
		"name": modelo.name,
		"url": modelo.url,
		"categories": modelo.categories,
		"subcategories": modelo.subcategories,
		"local_path": ruta_glb
	}

	var f_save = FileAccess.open(META_LOCAL_PATH, FileAccess.WRITE)
	f_save.store_string(JSON.stringify(data, "\t"))
	f_save.close()
	print(" Metadatos guardados.")
	note.text = "Modelo guardado con éxito"
	note.visible = true

func _on_back_button_pressed():
	self.visible = false
