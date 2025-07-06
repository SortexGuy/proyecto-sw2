extends Node3D

@export var models_container: Node3D

@onready var button_container = $UI/ButtonContainer

const MODEL_FOLDER = "res://models/"


var selected_model: Area3D = null 
var is_dragging: bool = false
var drag_offset: Vector3 = Vector3.ZERO


func _ready():
	var dir = DirAccess.open(MODEL_FOLDER)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".glb"):
				_create_model_button(file_name)
			file_name = dir.get_next()
		dir.list_dir_end()

func _create_model_button(file_name: String):
	var button = Button.new()
	button.text = file_name.get_basename()
	button.pressed.connect(_on_model_button_pressed.bind(file_name))
	button_container.add_child(button)


func _on_model_button_pressed(file_name: String):
	
	var new_model_root = Area3D.new()
	new_model_root.name = file_name.get_basename()

	new_model_root.input_event.connect(_on_model_input_event.bind(new_model_root))

	
	var model_path = MODEL_FOLDER + file_name
	var glb_data = load(model_path)
	if glb_data:
		var model_instance = glb_data.instantiate()
		new_model_root.add_child(model_instance)
		
		_add_collision_shape_to_area(new_model_root, model_instance)
		
		models_container.add_child(new_model_root)
		
		new_model_root.global_position = Vector3.ZERO
	else:
		print("Error: No se pudo cargar el modelo ", model_path)



func _add_collision_shape_to_area(area: Area3D, model_node: Node3D):
	
	var combined_aabb = AABB()
	var first_mesh = true

	
	var mesh_nodes = model_node.find_children("*", "MeshInstance3D", true)

	if mesh_nodes.is_empty():
		push_warning("El modelo '" + model_node.name + "' no contiene nodos MeshInstance3D. No se puede generar colisión.")
		return

	for mesh_node in mesh_nodes:
		var mesh_aabb = mesh_node.get_aabb()
		var global_mesh_aabb = mesh_node.global_transform * mesh_aabb
		
		if first_mesh:
			combined_aabb = global_mesh_aabb
			first_mesh = false
		else:
			combined_aabb = combined_aabb.merge(global_mesh_aabb)

	var local_aabb = area.global_transform.inverse() * combined_aabb

	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()

	box_shape.size = local_aabb.size
	collision_shape.shape = box_shape
	collision_shape.position = local_aabb.get_center()

	area.add_child(collision_shape)



func _on_model_input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, clicked_model: Area3D):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			selected_model = clicked_model 
			
			var mouse_pos = get_viewport().get_mouse_position()
			var ray_origin = camera.project_ray_origin(mouse_pos)
			var ray_dir = camera.project_ray_normal(mouse_pos)
		
			var plane = Plane(Vector3.UP, selected_model.global_position.y)
			var intersection = plane.intersects_ray(ray_origin, ray_dir)
			
			if intersection:
				drag_offset = selected_model.global_position - intersection
		else:
			
			is_dragging = false
			selected_model = null

func _input(event: InputEvent):
	if is_dragging and is_instance_valid(selected_model) and event is InputEventMouseMotion:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var ray_origin = camera.project_ray_origin(event.position)
			var ray_dir = camera.project_ray_normal(event.position)
			
			
			var plane = Plane(Vector3.UP, selected_model.global_position.y)
			var intersection = plane.intersects_ray(ray_origin, ray_dir)
			
			if intersection:
				selected_model.global_position = intersection + drag_offset

# CAMBIO 6: Deseleccionar si hacemos clic en el "vacío".
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		await get_tree().process_frame
		if is_dragging == false: 
			selected_model = null
