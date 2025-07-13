extends SubViewportContainer

# --- Variables para la cámara ---
@onready var cam_pivot: Marker3D = %CamPivot
@onready var cam_pitch: Marker3D = %CamPitch
@onready var camera_3d: Camera3D = %Camera3D
@onready var sub_viewport: SubViewport = $SubViewport

# --- Variables para el control de un modelo ---
# Referencia al nodo que contendrá los modelos 3D.
@onready var models_container: Node3D = %Models
var selected_model: Area3D = null 
var is_dragging: bool = false
var drag_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	# 1. Preguntamos al singleton (Autoload) si hay datos pendientes de cargar.
	var project_data = ProjectLoader.get_and_clear_data()
	
	# 2. Si el diccionario no está vacío, significa que venimos de "Cargar Proyecto".
	if not project_data.is_empty():
		print("WorldLayer: Datos de proyecto encontrados. Cargando modelos...")
		# 3. Llamamos a la función load_project_data para poblar la escena.
		load_project_data(project_data)
	else:
		print("WorldLayer: No se encontraron datos de proyecto. Iniciando escena vacía.")

#func _ready() -> void:
	#var area = $SubViewport/World/Area3D
	#area.input_event.connect(handle_input)
#
#func handle_input(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	#printerr(camera, event, event_position)
	#pass

# --- Función MODIFICADA _input() para manejar CÁMARA y ARRASTRE ---
func _input(event: InputEvent) -> void:
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	sub_viewport.push_input(event)
	# Primero, gestionamos la lógica de arrastrar el modelo.
	if is_dragging and is_instance_valid(selected_model) and event is InputEventMouseMotion:
		var ray_origin = camera_3d.project_ray_origin(event.position)
		var ray_dir = camera_3d.project_ray_normal(event.position)
		# Proyectamos sobre un plano horizontal a la altura del modelo.
		var plane = Plane(Vector3.UP, selected_model.global_position.y)
		var intersection = plane.intersects_ray(ray_origin, ray_dir)
		if intersection:
			selected_model.global_position = intersection + drag_offset
		return # Importante: Si estamos arrastrando, no movemos la cámara.

	# Si no estamos arrastrando, gestionamos la cámara (tu código original).
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
	

# --- Función AÑADIDA para deseleccionar el modelo ---
func _unhandled_input(event: InputEvent):
	for mouse_event in [InputEventMouseButton, InputEventMouseMotion, InputEventScreenDrag, InputEventScreenTouch]:
		if is_instance_of(event, mouse_event):
			# If the event is a mouse/touch event, then we can ignore it here, because it will be
			# handled via Physics Picking.
			return
	sub_viewport.push_unhandled_input(event)
	# Si hacemos clic con el botón izquierdo y no estamos empezando a arrastrar un modelo...
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		await get_tree().process_frame # Esperamos un frame para que is_dragging se actualice.
		if not is_dragging: 
			selected_model = null
			print("Modelo deseleccionado.")

# =====================================================================
# --- FUNCIONES AÑADIDAS PARA LA CREACIÓN Y MANIPULACIÓN DE MODELOS ---
# =====================================================================

# 1. ESTA ES LA FUNCIÓN QUE SERÁ LLAMADA POR LA SEÑAL DE LA UI
func add_model(model_url: String) -> Area3D:
	# Creamos un Area3D para que el modelo sea interactuable.
	var new_model_root = Area3D.new()
	new_model_root.name = model_url.get_file().get_basename()
	
	## CAMBIO 2: Guardamos la URL original en los metadatos para poder guardarla después.
	new_model_root.set_meta("model_url", model_url)

	new_model_root.input_ray_pickable = true
	# Conectamos la señal de input del área a nuestra función de manejo.
	# Pasamos el propio Area3D como argumento usando .bind()
	new_model_root.input_event.connect(_on_model_input_event.bind(new_model_root))
	
	# Cargamos la escena del modelo .glb
	var glb_data = load(model_url)
	if glb_data:
		var model_instance = glb_data.instantiate()
		new_model_root.add_child(model_instance)
		
		# Generamos una caja de colisión que envuelva al modelo.
		_add_collision_shape_to_area(new_model_root, model_instance)
		
		# Añadimos el nuevo modelo al contenedor 'Models' en la escena.
		models_container.add_child(new_model_root)
		
		# Lo colocamos en el origen del mundo para empezar.
		new_model_root.global_position = Vector3.ZERO
		print("Modelo '"+ new_model_root.name + "' añadido a la escena.")
	else:
		push_error("Error: No se pudo cargar el modelo " + model_url)
		## CAMBIO 3: Devolvemos null si falla.
		return null

	## CAMBIO 4: Devolvemos la referencia al nuevo modelo.
	return new_model_root


# 2. Función para generar la colisión del modelo (copiada de tu prueba).
func _add_collision_shape_to_area(area: Area3D, model_node: Node3D):
	var combined_aabb = AABB()
	var first_mesh = true
	var mesh_nodes = model_node.find_children("*", "MeshInstance3D", true)

	if mesh_nodes.is_empty():
		push_warning("El modelo '" + model_node.name + "' no contiene nodos MeshInstance3D. No se puede generar colisión.")
		return

	for mesh_node in mesh_nodes:
		var mesh_aabb = mesh_node.get_aabb()
		if first_mesh:
			combined_aabb = mesh_aabb
			first_mesh = false
		else:
			combined_aabb = combined_aabb.merge(mesh_aabb)

	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = combined_aabb.size
	collision_shape.shape = box_shape
	collision_shape.position = combined_aabb.position + combined_aabb.size / 2.0
	area.add_child(collision_shape)

# 3. Función que se ejecuta cuando se hace clic SOBRE un modelo.
func _on_model_input_event(event: InputEvent, _viewport: Viewport, _shape_idx: int, clicked_model: Area3D):
	print("¡Clic detectado sobre el modelo '", clicked_model.name, "'!")
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			selected_model = clicked_model
			
			# Calculamos el offset para un arrastre suave.
			var ray_origin = camera_3d.project_ray_origin(event.position)
			var ray_dir = camera_3d.project_ray_normal(event.position)
			var plane = Plane(Vector3.UP, selected_model.global_position.y)
			var intersection = plane.intersects_ray(ray_origin, ray_dir)
			
			if intersection:
				drag_offset = selected_model.global_position - intersection
		else:
			# Al soltar el botón del ratón.
			is_dragging = false
			# No deseleccionamos aquí para permitir seguir moviendo el ratón sin arrastrar.
			# La deselección se hace en _unhandled_input.


func save_project_data() -> Dictionary:
	"""
	Recopila los datos de todos los modelos en la escena y los devuelve
	como un diccionario listo para ser convertido a JSON.
	"""
	var models_data = []
	for model in models_container.get_children():
		# Solo guardamos nodos que son Area3D y tienen nuestros metadatos.
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


func load_project_data(project_data: Dictionary) -> void:
	"""
	Recibe datos de un proyecto, borra los modelos actuales y carga los nuevos.
	"""
	# 1. Borrar todos los modelos existentes
	for model in models_container.get_children():
		model.queue_free()

	# 2. Comprobar que los datos son válidos
	if not project_data.has("models") or not project_data["models"] is Array:
		push_error("El archivo de proyecto no tiene una lista de modelos válida.")
		return
		
	var models_to_load = project_data["models"]

	# 3. Cargar cada modelo de la lista
	for model_data in models_to_load:
		# Reutilizamos nuestra propia función `add_model` para crear el objeto.
		var new_model = add_model(model_data["url"])
		
		# Si se creó correctamente, le aplicamos la posición, rotación y escala guardadas.
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
