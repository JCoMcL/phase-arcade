class_name WorldEffects

static func duplicate_node_to_new_parent(n:Node, parent:Node) -> Node:
	var out = n.duplicate()
	parent.add_child(out)
	return out

static func create_temporary_sfx(basis:AudioStreamPlayer3D, parent:Node) -> AudioStreamPlayer3D:
	var out = duplicate_node_to_new_parent(basis, parent)
	out.play()
	out.finished.connect(out.queue_free)
	return out
