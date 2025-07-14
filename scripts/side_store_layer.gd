extends CanvasLayer

const API_MODELOS_URL: String = "http://localhost:3000/models"
const API_GLTF_URL: String = "http://localhost:3000/models/static/"
const API_METADATA_URL: String = "http://localhost:3000/models"
const META_LOCAL_PATH: String = "user://modelos_locales.json"

var modelos: Dictionary = {}
var modelo_en_descarga_id: int = -1

@onready var http: HTTPRequest = $HTTPRequest

@onready var boton_mesa_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Mesas1/Button
@onready var boton_mesa_2: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Mesas2/Button
@onready var boton_mesa_3: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Mesas3/Button
@onready var boton_sillas_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Sillas1/Button
@onready var boton_muebles_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Muebles1/Button
@onready var boton_sofas_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Sofas1/Button
@onready var boton_pisos_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Pisos/Button
@onready var boton_paredes_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Paredes/Button
@onready var boton_accesorios_1: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Cuadros/Button
@onready var boton_accesorios_2: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Ventanas/Button
@onready var boton_accesorios_3: Button = $PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer/Adornos/Button

func _ready() -> void:
	http.request_completed.connect(_on_https_request_completed)
	obtener_modelos_del_backend()

func obtener_modelos_del_backend() -> void:
	var err: int = http.request(API_MODELOS_URL)
	if err != OK:
		print("Error solicitando modelos:", err)

func _on_https_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		if modelo_en_descarga_id != -1 and body.size() > 0:
			guardar_archivo_glb(body)
			print("Modelo descargado exitosamente. ID:", modelo_en_descarga_id)
		elif modelo_en_descarga_id == -1 and body.size() > 0:
			var texto: String = body.get_string_from_utf8()
			var parsed_json: Variant = JSON.parse_string(texto)
			if typeof(parsed_json) == TYPE_DICTIONARY and parsed_json.has("data") and typeof(parsed_json["data"]) == TYPE_ARRAY:
				var parsed: Array = parsed_json["data"]
				for modelo in parsed:
					if typeof(modelo) == TYPE_DICTIONARY and modelo.has("id") and modelo.has("name"):
						modelo.id = int(modelo.id)
						modelos[modelo.id] = modelo
						_asignar_boton_existente(modelo)
					else:
						print("Modelo inválido:", modelo)
			else:
				print("La respuesta no contiene un arreglo en 'data':", parsed_json)
		else:
			print("⚠Respuesta HTTP 200 sin cuerpo útil.")
	else:
		print("Error HTTP:", response_code)

func _asignar_boton_existente(modelo: Dictionary) -> void:
	match modelo.name:
		"Mesa_pequeña", "mesa": boton_mesa_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Mesa_mediana", "mesa_mediana": boton_mesa_2.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Mesa_grande", "mesa_grande": boton_mesa_3.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Silla": boton_sillas_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Mueble": boton_muebles_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Sofa": boton_sofas_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Piso": boton_pisos_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Pared": boton_paredes_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Cuadro": boton_accesorios_1.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Ventana": boton_accesorios_2.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		"Adorno": boton_accesorios_3.pressed.connect(func(): _on_boton_modelo_presionado(modelo.id))
		_: print("Sin botón asignado para:", modelo.name)

func _on_boton_modelo_presionado(modelo_id: int) -> void:
	modelo_en_descarga_id = modelo_id
	var _ruta_glb: String = "user://downloads/modelo_" + str(modelo_id) + ".glb"
	var ya_guardado: bool = false

	if FileAccess.file_exists(META_LOCAL_PATH):
		var f: FileAccess = FileAccess.open(META_LOCAL_PATH, FileAccess.READ)
		var contenido: String = f.get_as_text()
		var parsed: Dictionary = JSON.parse_string(contenido)
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has(str(modelo_id)):
			var entrada: Dictionary = parsed[str(modelo_id)]
			if entrada.has("local_path") and FileAccess.file_exists(str(entrada["local_path"])):
				ya_guardado = true
		f.close()

	if ya_guardado:
		print("El modelo ya está disponible. No se descarga nuevamente.")
		modelo_en_descarga_id = -1
		return

	var url_descarga: String = API_GLTF_URL + str(modelo_id)
	var err: int = http.request(url_descarga)
	if err != OK:
		print("Error en la solicitud .glb:", err)

func guardar_archivo_glb(bytes: PackedByteArray) -> void:
	var ruta_glb: String = "user://downloads/modelo_" + str(modelo_en_descarga_id) + ".glb"

	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("downloads"):
		var result := dir.make_dir("downloads")
		if result != OK:
			print("No se pudo crear la carpeta 'downloads':", result)

	var file: FileAccess = FileAccess.open(ruta_glb, FileAccess.WRITE)
	if file:
		file.store_buffer(bytes)
		file.close()
		await guardar_metadatos_locales(modelo_en_descarga_id, ruta_glb)
		print("Modelo guardado correctamente en:", ruta_glb)
		print("Modelo descargado exitosamente. ID:", modelo_en_descarga_id)
	else:
		print("Error al guardar archivo:", ruta_glb)

	modelo_en_descarga_id = -1

func guardar_metadatos_locales(id: int, ruta_glb: String) -> void:
	var url: String = API_METADATA_URL + "/" + str(id)
	var http_meta: HTTPRequest = HTTPRequest.new()
	add_child(http_meta)

	http_meta.request_completed.connect(func(_r: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
		if code == 200:
			var texto: String = body.get_string_from_utf8()
			var metadata: Dictionary = JSON.parse_string(texto)
			if typeof(metadata) == TYPE_DICTIONARY:
				procesar_metadatos(id, metadata, ruta_glb)
			else:
				print("Metadatos en formato incorrecto.")
		else:
			print("Error al obtener metadatos:", code)
		http_meta.queue_free()
	)

	var err: int = http_meta.request(url)
	if err != OK:
		print("Error solicitando metadatos:", err)
		http_meta.queue_free()


func procesar_metadatos(id: int, metadata: Dictionary, ruta_glb: String) -> void:
	metadata["local_path"] = ruta_glb

	var db: Dictionary = {}
	if FileAccess.file_exists(META_LOCAL_PATH):
		var f: FileAccess = FileAccess.open(META_LOCAL_PATH, FileAccess.READ)
		var texto: String = f.get_as_text()
		var parsed: Dictionary = JSON.parse_string(texto)
		if typeof(parsed) == TYPE_DICTIONARY:
			db = parsed
		f.close()

	db[str(id)] = metadata

	var f_save: FileAccess = FileAccess.open(META_LOCAL_PATH, FileAccess.WRITE)
	if f_save:
		f_save.store_string(JSON.stringify(db, "\t"))
		f_save.close()
		print("Metadatos guardados para modelo ID:", id)
	else:
		print("Error al escribir archivo de metadatos.")

func _on_boton_volver_pressed() -> void:
	self.visible = false

