class_name SideStoreLayer

extends CanvasLayer

var store 
@onready var http := $HTTPRequest
@onready var http2 := $HTTPRequest2
@onready var back_button: Button = %BackButton

var buttons := []
var text := ""
var ID := 0

var categories = {}
var subcategories = {}
const link_categories := "http://localhost:3000/categories"

var Subcategories: Array = []
var processing := false

signal text_sent(texto: String, ID: int)

func _ready():
	var grid := get_node("PanelPrincipal/SideVista2MODELOS/VBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/GridContainer")
	for container in grid.get_children():
		if container.has_node("Button"):
			var button := container.get_node("Button")
			var string := container.name
			button.pressed.connect(func(nombre := string): connect_buttons(nombre))


	if store != null and store.has_method("receive_text"):
		connect("text_sent", Callable(store, "receive_text"))
	else:
		print("⚠No se encontró el nodo 'StoreLayer_Downloads' o no tiene el método 'receive_text'")

	http.request_completed.connect(_on_http_request_completed)
	http2.request_completed.connect(_on_http_request_2_completed)
	obtener_categorias()

func obtener_categorias():
	print("Solicitando categorías:", link_categories)
	var err = http.request(link_categories)
	if err != OK:
		print("Error solicitando categorías:", err)

func _on_http_request_completed(_result, response_code, _headers, body):
	if response_code == 200 and body.size() > 0:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("response"):
			var lista = parsed["response"].get("data", [])
			for c in lista:
				c.id = int(c.id)
				print("Categoría recibida:", c.name, "ID:", c.id)
				categories[c.id] = c
				revisar_subcategorias(c.id)
	else:
		print("Error HTTP:", response_code, " Body size:", body.size())

func revisar_subcategorias(id):
	if processing:
		Subcategories.append(id)
	else:
		trigger_subcategory(id)

func trigger_subcategory(id):
	processing = true
	var link_sub = "http://localhost:3000/categories/%d/subcategories?page=1&pageSize=10" % id
	var err = http2.request(link_sub)
	if err != OK:
		print("Error solicitando subcategorías:", err)

func _on_http_request_2_completed(_result, response_code, _headers, body):
	if response_code == 200 and body.size() > 0:
		var parsed = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("response"):
			var lista = parsed["response"].get("data", [])
			for s in lista:
				s.id = int(s.id)
				print("Subcategoría recibida:", s.name, "ID:", s.id)
				subcategories[s.id] = s
	processing = false
	if Subcategories.size() > 0:
		trigger_subcategory(Subcategories.pop_front())
	else:
		print("Subcategorías cargadas")

func connect_buttons(string: String):
	_on_item_pressed(string)

func _on_item_pressed(string):
	match string:
		"Mesas1": text = "Mesas pequeñas"
		"Mesas2": text = "Mesas medianas"
		"Mesas3": text = "Mesas grandes"
		"Sillas": text = "Sillas"
		"Muebles": text = "Muebles"
		"Sofas": text = "Sofás"
		"Pisos": text = "Pack de Pisos"
		"Paredes": text = "Pack de Paredes"
		"Cuadros": text = "Cuadros"
		"Ventanas": text = "Ventanas"
		"Adornos": text = "Adornos"
		_: print("Item desconocido:", string)

	for i in subcategories:
		if subcategories[i].name == text:
			ID = subcategories[i].id

	print("Emitiendo señal:", text, "ID:", ID)
	emit_signal("text_sent", text, ID)
	if store:
		store.visible = true

func _on_back_button_pressed():
	self.visible = false
