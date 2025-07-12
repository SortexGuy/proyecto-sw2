extends CanvasLayer

var buttons := []
var text := ""

signal texto_enviado(texto: String)

@onready var store = get_parent().get_node("StoreLayer_Downloads")

func _ready():
	var grid := get_node("PanelPrincipal2/SideVista2MODELOS/VBoxContainer/MarginContainer/ScrollContainer/GridContainer")

	for container in grid.get_children():
		if container.has_node("Button"):
			var button := container.get_node("Button")
			var string := container.name

			button.pressed.connect(func(nombre := string): connect_buttons(nombre))
			
	connect("texto_enviado", Callable(store, "recibir_texto"))


func connect_buttons(string: String):
	_on_item_pressed(string)

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
	
	print(text)
	emit_signal("texto_enviado", text)
	store.visible = true

#Botón volver
func _on_back_button_pressed():
	self.visible = false
