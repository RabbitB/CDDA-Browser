extends "res://nav_trees/generic_nav.gd"

const ExplorerAddressBar: Script = preload("res://explorer_address_bar/explorer_address_bar.gd")

export (NodePath) var _ExplorerAddressBarPath: NodePath

onready var _ExplorerAddressBar: ExplorerAddressBar = get_node(_ExplorerAddressBarPath) as ExplorerAddressBar


func _ready() -> void:
	
	_ExplorerAddressBar.connect("path_changed", self, "_on_ExplorerAddressBar_path_changed")


func _update_nav() -> bool:

	if !_ExplorerAddressBar.is_path_valid():
		return false

	var cdda_directory: FileSystemItem = FileSystemItem.new()
	cdda_directory.path = _ExplorerAddressBar.path

	_scan_files(cdda_directory, _SearchBar.text)
	emit_signal("nav_content_updated")

	return true


func _scan_files(files: FileSystemItem, filter: String = "") -> void:

	_NavTree.clear()

	var root_item = _NavTree.create_item()
	root_item.set_text(0, "CDDA")

	_scan_files_in_dir(files, root_item, true, filter)


func _scan_files_in_dir(directory: FileSystemItem, parent_in_tree: TreeItem, recursive: bool = false, filter: String = "") -> bool:

	var json_files_found: bool = false
	var json_files: Array = directory.list_files(true, "json")
	var sub_dirs: Array = directory.list_sub_directories(true)

	for json_file in json_files:

		if filter.empty() || json_file.findn(filter) != -1:

			json_files_found = true

			var new_item: TreeItem = _NavTree.create_item(parent_in_tree)
			new_item.set_text(0, json_file)
			new_item.set_metadata(0, directory.path.plus_file(json_file))

	if recursive:

		for sub_dir in sub_dirs:

			var new_dir: TreeItem = _NavTree.create_item(parent_in_tree)

			new_dir.set_text(0, sub_dir)
			new_dir.set_icon(0, preload("res://shared_icons/directory_icon.png"))
			new_dir.set_metadata(0, directory.path.plus_file(sub_dir))

			var sub_dir_has_json = _scan_files_in_dir(directory.get_child(sub_dir), new_dir, true, filter)

			if !sub_dir_has_json:
				parent_in_tree.remove_child(new_dir)
			else:
				json_files_found = true

	return json_files_found


func _on_ExplorerAddressBar_path_changed(path: String, is_path_valid: bool) -> void:
	_update_nav()


func _on_Tree_item_selected() -> void:

	var file: FileSystemItem = FileSystemItem.new()
	file.path = _NavTree.get_selected().get_metadata(0)

	emit_signal("nav_item_selected", file)

