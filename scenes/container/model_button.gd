extends PanelContainer

# Esta señal se emite HACIA AFUERA, para que el script principal sepa que este botón fue presionado.
signal button_was_pressed(model_url)

# Variables para guardar la información específica de este botón.
var model_url: String
var model_name: String

# Referencias a los nodos hijos para acceder a ellos fácilmente.
# Asegúrate de que los nombres coincidan con los de tu escena.
# Si no usas un Label, puedes borrar o comentar la línea correspondiente.
@onready var click_button: Button = %ClickButton
@onready var name_label: Label = %NameLabel

func _ready() -> void:
	# Es fundamental conectar la señal interna del botón a una función de este script.
	# Cuando el usuario presione el nodo "ClickButton"...
	click_button.pressed.connect(_on_internal_button_pressed)

# Esta función es pública para que el script principal pueda configurar cada botón al crearlo.
func setup(url: String, name: String) -> void:
	self.model_url = url
	self.model_name = name
	
	# Actualiza la UI del botón con el nombre del modelo.
	name_label.text = model_name
	click_button.text = "Seleccionar" # O puedes poner el nombre aquí también.

# Esta función se ejecuta CUANDO el "ClickButton" interno es presionado.
func _on_internal_button_pressed() -> void:
	# Ahora, emitimos NUESTRA PROPIA señal hacia el exterior, enviando la URL que tenemos guardada.
	button_was_pressed.emit(model_url)
	print("Botón presionado para el modelo: ", model_name) # Para depuración
