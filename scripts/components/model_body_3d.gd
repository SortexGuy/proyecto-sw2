class_name ModelBody3D
extends CharacterBody3D

const SNAP: float = 0.1

func _ready() -> void:
	self.collision_mask = 1 + 2
	pass

func move_to(dest: Vector3) -> bool:
	var vel := dest - global_position
	vel.x = snappedf(vel.x, SNAP)
	vel.z = snappedf(vel.z, SNAP)
	var coll := move_and_collide(vel, true, SNAP)
	if coll:
		var normal := coll.get_normal()
		var rem := coll.get_remainder()
		vel = coll.get_travel() + rem.slide(normal)

		# if not is_on_floor():
		var down_vel := Vector3.ZERO
		while coll and coll.get_normal() == get_floor_normal():
			down_vel += Vector3.DOWN*SNAP
			coll = move_and_collide(down_vel, true)
			# if not coll or coll.get_normal() != get_floor_normal(): break
		vel.y = down_vel.y
		# return false
	vel.x = snappedf(vel.x, SNAP)
	vel.z = snappedf(vel.z, SNAP)
	move_and_collide(vel, false, SNAP)
	apply_floor_snap()

	return true

