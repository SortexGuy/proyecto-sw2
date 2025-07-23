extends CanvasLayer

const API_MODELOS_URL := "http://localhost:3000/models"
const API_GLTF_URL := "http://localhost:3000/models/static/"
const META_LOCAL_PATH := "user://modelos_locales.json"

var modelos := {}
var modelo_en_descarga_id: Variant = null
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

func receive_text(text: String, ID: int):
	iD = ID
	print("Texto recibido:", text, "ID:", iD)
	label.text = text
	modelos.clear()
	note.visible = false

	for child in container.get_children():
		if child.name != "Note":
			child.queue_free()

	# Aseguramos una única conexión
	http.request_completed.disconnect(_on_http_request_completed)
	http.request_completed.connect(_on_http_request_completed)

	obtener_modelos()

func obtener_modelos():
	print("Solicitando modelos desde:", API_MODELOS_URL)
	http.timeout = 5
	var err = http.request(API_MODELOS_URL)
	if err != OK:
		print("Error al solicitar modelos:", err)

func _on_http_request_completed(_result, response_code, _headers, body):
	print("Respuesta HTTP:", response_code, "| Descargando:", modelo_en_descarga_id)

	if response_code == 200 and body.size() > 0:
		if modelo_en_descarga_id == null:
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("data"):
				var lista = parsed["data"]
				for modelo in lista:
					modelo.id = int(modelo.id)
					print("Modelo:", modelo.name, "ID:", modelo.id, "Categorías:", modelo.categories)
					note.text = "En este momento no hay archivos\ndisponibles"

					# Se recomienda usar `if iD in modelo.subcategories` para mayor flexibilidad
					if typeof(modelo.subcategories) == TYPE_ARRAY and iD in modelo.subcategories:
						modelos[modelo.id] = modelo
				generar_botones(modelos)
		else:
			print("Descarga completada, guardando modelo ID:", modelo_en_descarga_id)
			guardar_archivo_glb(body)
	else:
		print("Fallo HTTP:", response_code, " Body:", body.size())
		if modelo_en_descarga_id != null:
			modelo_en_descarga_id = null
		note.text = "Modelo inválido o no disponible" if body.size() == 33 else "No se pudo conectar con el servidor"
		modelos.clear()
		generar_botones(modelos)

func generar_botones(modelos_dict):
	note.visible = modelos_dict == {}
	for id in modelos_dict:
		var modelo = modelos_dict[id]
		var btn := button.duplicate()
		btn.name = modelo.name
		btn.text = modelo.name
		btn.visible = true
		btn.pressed.connect(_on_button_model_pressed.bind(modelo.id))
		container.add_child(btn)

func _on_button_model_pressed(modelo_id):
	note.visible = false
	print("Botón presionado, solicitando modelo ID:", modelo_id)
	modelo_en_descarga_id = int(modelo_id)
	var ruta = "downloads/modelo_%d.glb" % modelo_en_descarga_id

	if FileAccess.file_exists(ruta):
		print("Ya está disponible en disco:", ruta)
		note.text = "El modelo ya se encuentra disponible\nen la aplicación"
		note.visible = true
		modelo_en_descarga_id = null
		return

	var url_descarga = API_GLTF_URL + str(modelo_en_descarga_id)
	print("Descargando desde:", url_descarga)
	var err = http.request(url_descarga)
	if err != OK:
		print("Error solicitando GLB:", modelo_en_descarga_id)

func guardar_archivo_glb(bytes):
	var carpeta = "downloads"
	var ruta = "%s/modelo_%d.glb" % [carpeta, modelo_en_descarga_id]

	var dir = DirAccess.open("res://")
	if not dir.dir_exists(carpeta):
		var err = dir.make_dir(carpeta)
		if err != OK:
			print("Error creando carpeta:", err)
			return

	print("Guardando archivo en:", ruta)
	var file = FileAccess.open(ruta, FileAccess.WRITE)
	if file:
		file.store_buffer(bytes)
		file.close()
		guardar_metadatos_locales(modelo_en_descarga_id, ruta)
	else:
		print("Error al abrir el archivo")

	modelo_en_descarga_id = null

func guardar_metadatos_locales(id, ruta_glb):
	print("Guardando metadatos para modelo ID:", id)
	var data := {}

	if FileAccess.file_exists(META_LOCAL_PATH):
		var f = FileAccess.open(META_LOCAL_PATH, FileAccess.READ)
		var contenido = f.get_as_text()
		var parsed = JSON.parse_string(contenido)
		if typeof(parsed) == TYPE_DICTIONARY:
			data = parsed
		else:
			print("⚠️ Archivo malformado o vacío, reiniciando")
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
	print("Metadatos guardados exitosamente")
	note.text = "Modelo guardado con éxito"
	note.visible = true

func _on_back_button_pressed():
	self.visible = false

