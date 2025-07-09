extends CanvasLayer

const API_MODELOS_URL := "http://localhost:3000/models/all"
const API_GLTF_URL := "http://localhost:3000/models/static/"
const META_LOCAL_PATH := "user://modelos_locales.json"

var modelos = {}
var modelo_en_descarga_id = null

@onready var http := $HTTPRequest

@onready var boton_mesa_1 := %Mesa1Button
@onready var boton_mesa_2 := %Mesa2Button
@onready var boton_mesa_3 := %Mesa3Button
@onready var back_button: Button = %BackButton

func _ready():
	back_button.pressed.connect(_on_back_button_pressed)
	print(" Conectando y solicitando modelos...")
	http.request_completed.connect(_on_https_request_completed)
	obtener_modelos_del_backend()

func obtener_modelos_del_backend():
	print("Solicitando modelos desde el backend:", API_MODELOS_URL)
	var err = http.request(API_MODELOS_URL)
	if err != OK:
		print(" Error al solicitar modelos:", err)

func _on_https_request_completed(_result, response_code, _headers, body):
	print(" Respuesta HTTP recibida. Código:", response_code, " Modelo en descarga:", modelo_en_descarga_id)
	if response_code == 200 and body.size() > 0:
		if modelo_en_descarga_id == null:
			print(" Cargando lista de modelos")
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_ARRAY:
				for modelo in parsed:
					modelo.id = int(modelo.id)
					print(" Modelo recibido:", modelo.name, " ID:", modelo.id)
					modelos[modelo.id] = modelo
					_asignar_boton_existente(modelo)
		else:
			print(" Descarga de modelo ID:", modelo_en_descarga_id, " completada. Guardando...")
			guardar_archivo_glb(body)
	else:
		print("Error HTTP:", response_code, " Body size:", body.size())

func _asignar_boton_existente(modelo):
	match modelo.name:
		"Mesa":
			boton_mesa_1.pressed.connect(func(): _on_boton_modelo_presionado(int(modelo.id)))
		"Mesa_2":
			boton_mesa_2.pressed.connect(func(): _on_boton_modelo_presionado(int(modelo.id)))
		"Mesa_3":
			boton_mesa_3.pressed.connect(func(): _on_boton_modelo_presionado(int(modelo.id)))
		_:
			print(" No hay botón predefinido para:", modelo.name)

func _on_boton_modelo_presionado(modelo_id):
	print(" Botón presionado. Solicitando modelo ID:", modelo_id)
	modelo_en_descarga_id = int(modelo_id)
	var ruta = "downloads/modelo_" + str(modelo_en_descarga_id) + ".glb"
	
	if FileAccess.file_exists(ruta):
		print("El modelo ya se encuentra disponible en la aplicación.")
		modelo_en_descarga_id = null
		return
	
	var url_descarga = API_GLTF_URL + str(modelo_en_descarga_id)  
	print(" Solicitando:", url_descarga)
	var err = http.request(url_descarga)
	if err != OK:
		print(" Error solicitando .glb del modelo:", modelo_en_descarga_id)

func guardar_archivo_glb(bytes):
	var ruta = "downloads/modelo_" + str(modelo_en_descarga_id) + ".glb"
	print("Guardando .glb en: ", ruta)
	var file = FileAccess.open(ruta, FileAccess.WRITE)
	file.store_buffer(bytes)
	file.close()
	
	guardar_metadatos_locales(modelo_en_descarga_id, ruta)
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

#Botón volver
func _on_back_button_pressed():
	self.visible = false
