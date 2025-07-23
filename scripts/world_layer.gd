extends SubViewportContainer

@onready var cam_pivot: Marker3D = %CamPivot
@onready var cam_pitch: Marker3D = %CamPitch
@onready var camera_3d: Camera3D = %Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var models_container: Node3D = %Models
@onready var room: CSGBox3D = %Room

var selected_model: ModelBody3D = null
var is_dragging: bool = false
var drag_offset: Vector3 = Vector3.ZERO

func resize_room(width, depth) -> void:
	room.size = Vector3(width, room.size.y,depth)
	pass

func _ready() -> void:
	var project_data := ProjectLoader.get_and_clear_data()
	if not project_data.is_empty():
		print("WorldLayer: Datos de proyecto encontrados. Cargando modelos...")
		load_project_data(project_data)
	else:
		print("WorldLayer: No se encontraron datos de proyecto. Iniciando escena vacía.")

func _input(event: InputEvent) -> void:
	# Lógica de arrastrar el modelo.
	if is_dragging and is_instance_valid(selected_model) and event is InputEventScreenDrag and event.index == 0:
		var ray_origin := camera_3d.project_ray_origin(event.position)
		var ray_dir := camera_3d.project_ray_normal(event.position)
		# Proyectamos sobre un plano horizontal a la altura del modelo.
		var plane := Plane(Vector3.UP, selected_model.global_position.y)
		var intersection := plane.intersects_ray(ray_origin, ray_dir) as Vector3
		if intersection:
			selected_model.move_to(intersection + drag_offset)
			# selected_model.global_position = intersection + drag_offset
		return # Importante: Si estamos arrastrando, no movemos la cámara.

	if event is InputEventGesture:
		event = event as InputEventGesture
		if event is InputEventMagnifyGesture:
			event = event as InputEventMagnifyGesture
			camera_3d.translate(Vector3.FORWARD * (event.factor-1) * 10)
			camera_3d.position.z = clampf(camera_3d.position.z, 2, 50)
		if event is InputEventPanGesture:
			event = event as InputEventPanGesture
			cam_pivot.quaternion *= Quaternion(Vector3.UP, event.delta.x * 0.01)
			cam_pitch.quaternion *= Quaternion(Vector3.RIGHT, event.delta.y * 0.005)
			cam_pitch.rotation_degrees.x = clampf(cam_pitch.rotation_degrees.x, -85, 15)

func _unhandled_input(event: InputEvent):
	if event is InputEventScreenTouch and event.index == 0 and event.is_pressed():
		await get_tree().process_frame
		if not is_dragging:
			selected_model = null
			print("Modelo deseleccionado.")

func add_model(model_url: String) -> CollisionObject3D:
	var new_model_root := ModelBody3D.new()
	new_model_root.name = model_url.get_file().get_basename()
	new_model_root.set_meta("model_url", model_url) # Guardamos la URL original en los metadatos

	new_model_root.input_ray_pickable = true
	new_model_root.input_event.connect(_on_model_input_event.bind(new_model_root))

	var glb_data := load(model_url)
	if glb_data:
		var model_instance: Node3D = glb_data.instantiate()
		new_model_root.add_child(model_instance)
		_add_collision_shape_to_root(new_model_root, model_instance)
		models_container.add_child(new_model_root)

		new_model_root.global_position = Vector3.ZERO
		new_model_root.global_position.y += 0.2
		print("Modelo '"+ new_model_root.name + "' añadido a la escena.")
	else:
		push_error("Error: No se pudo cargar el modelo " + model_url)
		return null

	return new_model_root

func _add_collision_shape_to_area(area: Area3D, model_node: Node3D):
	var mesh_nodes := model_node.find_children("*", "MeshInstance3D", true)

	if mesh_nodes.is_empty():
		push_warning("El modelo '" + model_node.name + "' no contiene nodos MeshInstance3D. No se puede generar colisión.")
		return

	for mesh_node in mesh_nodes:
		mesh_node = mesh_node as MeshInstance3D
		var collision_shape := CollisionShape3D.new()
		area.add_child(collision_shape)
		await get_tree().process_frame
		var box_shape: ConvexPolygonShape3D = mesh_node.mesh.create_convex_shape()
		collision_shape.shape = box_shape
		collision_shape.global_transform = mesh_node.global_transform

func _add_collision_shape_to_root(root: CollisionObject3D, model_node: Node3D):
	var mesh_nodes := model_node.find_children("*", "MeshInstance3D", true)

	if mesh_nodes.is_empty():
		push_warning("El modelo '" + model_node.name + "' no contiene nodos MeshInstance3D. No se puede generar colisión.")
		return

	for mesh_node in mesh_nodes:
		mesh_node = mesh_node as MeshInstance3D
		var collision_shape := CollisionShape3D.new()
		root.add_child(collision_shape)

		await get_tree().process_frame
		var box_shape: ConvexPolygonShape3D = mesh_node.mesh.create_convex_shape()
		collision_shape.shape = box_shape
		collision_shape.global_transform = mesh_node.global_transform

func _on_model_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int, clicked_model: CollisionObject3D):
	print("¡Clic detectado sobre el modelo '", clicked_model.name, "'!")
	if event is InputEventScreenTouch and event.index == 0:
		if event.is_pressed() and clicked_model is ModelBody3D:
			is_dragging = true
			selected_model = clicked_model

			var ray_origin = camera_3d.project_ray_origin(event.position)
			var ray_dir = camera_3d.project_ray_normal(event.position)
			var plane = Plane(Vector3.UP, selected_model.global_position.y)
			var intersection = plane.intersects_ray(ray_origin, ray_dir)

			if intersection:
				drag_offset = selected_model.global_position - intersection
		else:
			is_dragging = false

## Recopila los datos de todos los modelos en la escena y los devuelve
## como un diccionario listo para ser convertido a JSON.
func save_project_data() -> Dictionary:
	var models_data = []
	for model in models_container.get_children():
		if model is Area3D and model.has_meta("model_url"):
			var data = {
				"url": model.get_meta("model_url"),
				"position": [model.global_position.x, model.global_position.y, model.global_position.z],
				"rotation": [model.rotation_degrees.x, model.rotation_degrees.y, model.rotation_degrees.z],
				"scale": [model.scale.x, model.scale.y, model.scale.z]
			}
			models_data.append(data)

	var project_data = {
		"version": "1.0",
		"models": models_data
	}
	return project_data


## Recibe datos de un proyecto, borra los modelos actuales y carga los nuevos.
func load_project_data(project_data: Dictionary) -> void:
	for model in models_container.get_children():
		model.queue_free()

	if not project_data.has("models") or not project_data["models"] is Array:
		push_error("El archivo de proyecto no tiene una lista de modelos válida.")
		return

	var models_to_load = project_data["models"]
	for model_data in models_to_load:
		var new_model = add_model(model_data["url"])

		if is_instance_valid(new_model):
			new_model.global_position = Vector3(
				model_data["position"][0], model_data["position"][1], model_data["position"][2]
			)
			new_model.rotation_degrees = Vector3(
				model_data["rotation"][0], model_data["rotation"][1], model_data["rotation"][2]
			)
			new_model.scale = Vector3(
				model_data["scale"][0], model_data["scale"][1], model_data["scale"][2]
			)
