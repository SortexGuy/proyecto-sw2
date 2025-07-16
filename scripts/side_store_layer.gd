extends CanvasLayer

@onready var store = get_parent().get_node("StoreLayer_Downloads")
@onready var http = $HTTPRequest
@onready var http2 = $HTTPRequest2
@onready var back_button: Button = %BackButton

var buttons := []
var text := ""
var ID := 0

var categories = {}
var category = null
var subcategories = {}
var subcategory = null
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
			
	connect("text_sent", Callable(store, "receive_text"))
	
	http.request_completed.connect(_on_http_request_completed)
	http2.request_completed.connect(_on_http_request_2_completed)
	obtener_categorias()

#Se obtienen las categorías
func obtener_categorias():
	print("Categorías: ", link_categories)
	
	var err = http.request(link_categories)
	if err != OK:
		print(" Error al solicitar categorías:", err)

func _on_http_request_completed(result, response_code, headers, body):
	print(" Respuesta HTTP recibida. Código:", response_code, " Categoría:", category)

	if response_code == 200 and body.size() > 0:
		if category == null:
			print(" Cargando categorías")
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("response"):
				var inner = parsed["response"]
				if typeof(inner) == TYPE_DICTIONARY and inner.has("data"):
					var lista = inner["data"]
					for c in lista:
						c.id = int(c.id)
						print(" Categoría recibida: ", c.name, " ID:", c.id)
						categories[c.id] = c
						
						revisar_subcategorias(c.id)
	else:
		print("Error HTTP:", response_code, " Body size: ", body.size())

#Se revisan las subcategorías con un trigger
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
		print(" Error al solicitar subcategorías:", err)

func _on_http_request_2_completed(result, response_code, headers, body):
	print(" Respuesta HTTP recibida. Código:", response_code, " Categoría:", subcategory)

	if response_code == 200 and body.size() > 0:
		if subcategory == null:
			print(" Cargando subcategorías")
			var parsed = JSON.parse_string(body.get_string_from_utf8())
			if typeof(parsed) == TYPE_DICTIONARY and parsed.has("response"):
				var inner = parsed["response"]
				if typeof(inner) == TYPE_DICTIONARY and inner.has("data"):
					var lista = inner["data"]
					for s in lista:
						s.id = int(s.id)
						print(" Subcategoría recibida: ", s.name, " ID: ", s.id)
						subcategories[s.id] = s
						
		processing = false
		if Subcategories.size() > 0:
			var next_id = Subcategories.pop_front()
			trigger_subcategory(next_id)
	else:
		print("Error HTTP:", response_code, " Body size:", body.size())

#Se conectan los botones con el nombre de su label
func connect_buttons(string: String):
	_on_item_pressed(string)

#Se envía el nombre de la subcategoría y su id
func _on_item_pressed(string):
	match string:
		"Mesas1":
			text = "Mesas pequeñas"
		"Mesas2":
			text = "Mesas medianas"
		"Mesas3":
			text = "Mesas grandes"
		"Sillas":
			text = "Sillas"
		"Muebles":
			text = "Muebles"
		"Sofas":
			text = "Sofás"
		"Pisos":
			text = "Pack de Pisos"
		"Paredes":
			text = "Pack de Paredes"
		"Cuadros":
			text = "Cuadros"
		"Ventanas":
			text = "Ventanas"
		"Adornos":
			text = "Adornos"
		_:
			print("item desconocido")
		
	for i in subcategories:
		if subcategories[i].name == text:
			ID = subcategories[i].id
	
	print("Texto enviado: ", text,". ID: ", ID)
	emit_signal("text_sent", text, ID)
	store.visible = true

#Botón volver
func _on_back_button_pressed():
	self.visible = false
