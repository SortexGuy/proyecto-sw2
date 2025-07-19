extends CanvasLayer

signal model_selected(url)

@export var models_path: String = "res://models"
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

	var dir := DirAccess.open(models_path)
	if dir:
		var model_button := load(model_button_scene) as PackedScene
		for file_name in dir.get_files():
			if file_name.ends_with(".glb"):
				var new_button = model_button.instantiate()

				var model_path = models_path.path_join(file_name)
				var display_name = file_name.get_basename() # "mi_modelo.glb" -> "mi_modelo"

				buttons_container.add_child(new_button)
				new_button.setup(model_path, display_name)
				new_button.button_was_pressed.connect(_on_model_button_pressed)
	else:
		push_error("No se pudo abrir el directorio de modelos en: " + models_path)

func _on_model_button_pressed(url_del_modelo: String) -> void:
	print("Se ha seleccionado un modelo en la capa de UI. URL: ", url_del_modelo)
	model_selected.emit(url_del_modelo)
	self.visible = false
