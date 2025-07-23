extends CanvasLayer

signal model_selected(url)

const MODELS_PATH: String = AppManager.PREFIX_DIR + AppManager.MODELS_FOLDER

@export_file("*.tscn", "*.scn") var model_button_scene: String = "res://scenes/components/model_button.tscn"
@onready var buttons_container := %ButtonsContainer

func _ready() -> void:
	visibility_changed.connect(func():
		if visible:
			populate_model_list()
		pass)

func populate_model_list() -> void:
	for child in buttons_container.get_children():
		child.queue_free()

	var file := FileAccess.get_file_as_string(AppManager.PREFIX_DIR + AppManager.META_LOCAL)
	if file.is_empty():
		push_error("No se pudo abrir el archivo de modelos en: " + AppManager.META_LOCAL)
		return
	var parsed := JSON.parse_string(file) as Dictionary
	var model_button := load(model_button_scene) as PackedScene
	for model in parsed.values():
		model = model as Dictionary
		print("\n", model)
		var new_button = model_button.instantiate()

		var model_path = model.local_path
		var display_name = (model.name as String).capitalize()

		buttons_container.add_child(new_button)
		new_button.setup(model_path, display_name)
		new_button.button_was_pressed.connect(_on_model_button_pressed)

func _on_model_button_pressed(url_del_modelo: String) -> void:
	print("Se ha seleccionado un modelo en la capa de UI. URL: ", url_del_modelo)
	model_selected.emit(url_del_modelo)
	self.visible = false

