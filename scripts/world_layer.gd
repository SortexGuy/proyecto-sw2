extends CanvasLayer

@onready var cam_pivot: Marker3D = %CamPivot
@onready var cam_pitch: Marker3D = %CamPitch
@onready var camera_3d: Camera3D = %Camera3D

func _input(event: InputEvent) -> void:
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
		pass
	pass
