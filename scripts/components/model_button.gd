extends PanelContainer

signal button_was_pressed(model_url)

@onready var click_button: Button = %ClickButton
@onready var name_label: Label = %NameLabel

var model_url: String
var model_name: String

func _ready() -> void:
	click_button.pressed.connect(_on_internal_button_pressed)

func setup(url: String, m_name: String) -> void:
	self.model_url = url
	self.model_name = m_name

	name_label.text = model_name
	click_button.text = "Seleccionar" # O puedes poner el nombre aquí también.

func _on_internal_button_pressed() -> void:
	button_was_pressed.emit(model_url)
	print("Botón presionado para el modelo: ", model_name) # Para depuración
