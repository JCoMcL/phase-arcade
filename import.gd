@tool # Needed so it runs in editor.
extends EditorScenePostImport

## The all-purpose import script

func is_file_type(ext:String) -> bool:
	return get_source_file().get_extension().to_lower() == ext.to_lower()

func file_suffix(suffix:String) -> bool:
	return get_source_file().get_basename().ends_with(suffix)

# --- Asset Extraction ---

func extract_asset(asset:Node, path:String, scene_name:String) -> bool:
	if asset is Node3D:
		asset.position = Vector3.ZERO
		if is_file_type("FBX"):
			pass # put something there if needed
		asset.rotation = Vector3.ZERO
		# Leaving scale alone

	asset.name = scene_name.to_pascal_case()
	asset.owner = null
	adopt(asset, asset)

	var packed := PackedScene.new()
	var pack_err := packed.pack(asset)
	if pack_err != OK:
		push_error("Import: can't pack %s (%s)" % [
			asset.name, error_string(pack_err)
		])
		return false

	var save_err := ResourceSaver.save(packed, path)
	if save_err != OK:
		push_error("Import: can't save %s (%s)" % [path, error_string(save_err)])
		return false
	print("[Import] %s -> %s" % [asset.name, path])
	return true

# required because of Godot ownership rules. Otherwise sub-nodes are not included
func adopt(node:Node, root:Node) -> void:
	for child in node.get_children():
		child.owner = root
		adopt(child, root)

func split_assets(scene:Node) -> void:
	var source := get_source_file()
	var out_dir := source.get_base_dir()
	# controlsAssets.glb -> _controls_joystick.tscn, next to the model
	var prefix := "_%s_" % source.get_basename().get_file() \
		.trim_suffix("Assets").to_snake_case()

	var taken:Dictionary = {}
	for asset in scene.get_children():
		var scene_name := String(asset.name).to_snake_case().validate_filename()
		if taken.has(scene_name):
			push_warning("Import: %s and %s both want to be %s" % [
				taken[scene_name], asset.name, scene_name
			])
		else:
			taken[scene_name] = asset.name
		var path := "%s%s.tscn" % [prefix, scene_name]
		extract_asset(asset, out_dir.path_join(path), scene_name)

# --- Main ---

var root_scene: Node
func _post_import(scene):
	root_scene=scene
	if file_suffix("Assets"):
		split_assets(scene)
	else:
		iterate(scene, scene)
	return scene

func iterate(node:Node, root:Node, depth:int=0):
	if not node:
		return

	for child in node.get_children():
		iterate(child, root, depth+1)
