extends RigidBody3D
class_name Door

func open():
	apply_impulse(Vector3.FORWARD * 3, $InteractZone.position)
	get_parent().get_node("HingeJoint3D").set("motor/enable", false)

func close():
	apply_impulse(Vector3.FORWARD * -3, $InteractZone.position)
	get_parent().get_node("HingeJoint3D").set("motor/enable", true)
