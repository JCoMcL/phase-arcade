@tool
extends EditorScript

func _run() -> void:
	var fs := EditorInterface.get_resource_filesystem()
	var paths := get_model_paths()

	if paths.is_empty():
		print("[Reimport FBX/GLB] No .fbx or .glb files found in res://.")
		return

	fs.reimport_files(paths)
	print("[Reimport FBX/GLB] Reimported %d file(s)." % paths.size())

func get_model_paths() -> PackedStringArray:
	var result := PackedStringArray()
	var dir := DirAccess.open("res://")
	if dir == null:
		return result
	_scan_recursive(dir, result)
	return result

func _scan_recursive(dir: DirAccess, out: PackedStringArray) -> void:
	dir.list_dir_begin()
	var file := dir.get_next()
	while file != "":
		if dir.current_is_dir() and not file.begins_with("."):
			var sub_path := dir.get_current_dir().path_join(file)
			var sub := DirAccess.open(sub_path)
			if sub != null:
				_scan_recursive(sub, out)
		elif not dir.current_is_dir():
			var lower := file.to_lower()
			if lower.ends_with(".fbx") or lower.ends_with(".glb"):
				out.append(dir.get_current_dir().path_join(file))
		file = dir.get_next()
	dir.list_dir_end()
