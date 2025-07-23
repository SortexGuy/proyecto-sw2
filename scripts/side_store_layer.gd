class_name SideStoreLayer
extends CanvasLayer

signal subcat_button_pressed(cats_desc: Dictionary)
signal text_sent(texto: String, ID: int)

var CAT_SERVER_URL: String = AppManager.SERVER_URL + "categories"
@export_file("*.tscn", "*.scn") var cats_templ: String = "res://scenes/components/cat_template.tscn"

@onready var http :HTTPRequest= $HTTPRequest
@onready var http2 :HTTPRequest= $HTTPRequest2
@onready var back_button: Button = %BackButton
@onready var categories_container: VBoxContainer = %CategoriesContainer

var store
var buttons := []
var text := ""
var ID := 0
var categories = {}
var curr_cat_id: int = -1
var subcategories = {}
var subcategory = null
var _subcategories: Array[int] = []
var processing := false

func _ready():
	self.visibility_changed.connect(_on_visibility_changed)

func setup() -> void:
	for c in categories_container.get_children():
		c.queue_free()
	await get_tree().process_frame

	if store != null and store.has_method("receive_text"):
		connect("text_sent", Callable(store, "receive_text"))
	else:
		print("⚠No se encontró el nodo 'StoreLayer_Downloads' o no tiene el método 'receive_text'")

	http.request_completed.connect(_on_http_request_completed)
	http2.request_completed.connect(_on_http_request_2_completed)
	obtener_categorias()

func populate() -> void:
	var cats_scene: PackedScene = load(cats_templ)

	for cat in categories.values():
		var item: CatTemplate = cats_scene.instantiate()
		categories_container.add_child(item)
		item.setup(cat)
		item.subcat_button_pressed.connect(subcat_button_pressed.emit)
	pass

func _on_visibility_changed() -> void:
	if not visible: return
	setup()

func obtener_categorias():
	print("Solicitando categorías:", CAT_SERVER_URL)
	var err = http.request(CAT_SERVER_URL)
	if err != OK:
		print("Error solicitando categorías:", err)

## respuesta de http(1)
func _on_http_request_completed(_result, response_code, _headers, body: PackedByteArray):
	var parsed: Dictionary
	if response_code != 200 or body.size() < 0:
		print("Error HTTP:", response_code, " Body size:", body.size())
		if body.size() > 0:
			parsed = JSON.parse_string(body.get_string_from_utf8())
			print(parsed)
		return
	parsed = JSON.parse_string(body.get_string_from_utf8())
	if not parsed.has("response"):
		printerr("Not well contructed response")
		return

	var lista := (parsed["response"] as Dictionary).get("data", []) as Array
	for c in lista:
		c = c as Dictionary
		c.id = int(c.id)
		print("Categoría recibida:", c.name, "ID:", c.id)
		categories[c.id] = c
		revisar_subcategorias(c.id)

func revisar_subcategorias(id: int):
	if processing:
		_subcategories.append(id)
	else:
		trigger_subcategory(id)

func trigger_subcategory(id: int):
	processing = true
	curr_cat_id = id
	var link_sub := AppManager.SERVER_URL + ("categories/%d/subcategories?page=1&pageSize=20" % id)
	print(link_sub)
	var err := http2.request(link_sub)
	if err != OK:
		print("Error solicitando subcategorías:", err)

## respuesta de http2
func _on_http_request_2_completed(_result, response_code, _headers, body):
	var parsed := JSON.parse_string(body.get_string_from_utf8()) as Dictionary
	if response_code == 200 and body.size() > 0:
		if typeof(parsed) == TYPE_DICTIONARY and parsed.has("response"):
			parsed = parsed as Dictionary
			var lista := (parsed["response"] as Dictionary).get("data", []) as Array
			var subcats: Dictionary
			for s in lista:
				s = s as Dictionary
				s.id = int(s.id)
				print("Subcategoría recibida:", s.name, "ID:", s.id)
				subcats[s.id] = s
			categories[curr_cat_id].subcategories = subcats
	else:
		print("Subcategories")
		print("Error HTTP:", response_code, " Body size:", body.size())
		print(parsed)

	processing = false
	if _subcategories.size() > 0:
		trigger_subcategory(_subcategories.pop_front())
	else:
		populate()
		print("Subcategorías cargadas")

func _on_back_button_pressed():
	self.visible = false
