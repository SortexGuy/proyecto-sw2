class_name LoadProjectLayer
extends CanvasLayer

const PROJECT_PATH: String = "projects"
@export var project_item_sample: PackedScene
@onready var back_button: Button = %BackButton
@onready var projects_container: VBoxContainer = %ProjectsContainer

func load_project_list() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists(PROJECT_PATH):
		#dir.make_dir(PROJECT_PATH)
		return
	dir.change_dir(PROJECT_PATH)
	
	for c in projects_container.get_children():
		c.queue_free()
	
	for file in dir.get_files():
		if not file.ends_with(".prj"):
			continue
		#var project := FileAccess.open(file, FileAccess.READ)
		var sample_node: SampleProjectItem = project_item_sample.instantiate()
		projects_container.add_child(sample_node, true)
		sample_node.project_label.text = file.trim_suffix(".prj").capitalize()
		sample_node.project_url = file
	pass

func _ready() -> void:
	load_project_list()
	pass
