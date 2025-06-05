extends Node

func _ready() -> void:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	http_request.download_file = "./models/pico.glb"

	# Perform the HTTP request. The URL below returns a PNG image as of writing.
	var error := http_request.request("http://localhost:3000/static/pico.glb")
	if error != OK:
		push_error("An error occurred in the HTTP request: (error code: %s)." % error_string(error))

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("File couldn't be downloaded.")
	push_warning(headers)
	# Load an existing glTF scene.
	# GLTFState is used by GLTFDocument to store the loaded scene's state.
	# GLTFDocument is the class that handles actually loading glTF data into a Godot node tree,
	# which means it supports glTF features such as lights and cameras.
	var gltf_document_load = GLTFDocument.new()
	var gltf_state_load = GLTFState.new()
	var error = gltf_document_load.append_from_file("./models/pico.glb", gltf_state_load)
	if error == OK:
		var gltf_scene_root_node := gltf_document_load.generate_scene(gltf_state_load)
		add_child(gltf_scene_root_node)
	else:
		push_error("Couldn't load glTF scene (error code: %s)." % error_string(error))
