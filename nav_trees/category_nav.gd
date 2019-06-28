extends "generic_nav.gd"

export (NodePath) var display_location_path

var current_category_viewer: Node
var _display_location: Node
var _stored_scenes: Dictionary = {}


func _ready():
	_setup_contents()


func _setup_contents() -> void:

	_display_location = get_node(display_location_path)

	var root_item: TreeItem = _NavTree.create_item()
	root_item.set_text(0, "Categories")

	_create_category("Colors", preload("res://category_views/colors.tscn"))


func _create_category(name: String, scene_to_use: PackedScene, parent: TreeItem = null) -> void:

	var category_info: Dictionary = { "name": name, "scene": scene_to_use }

	var new_category_item: TreeItem = _NavTree.create_item(parent)
	new_category_item.set_text(0, name)
	new_category_item.set_metadata(0, category_info)


func _on_Tree_item_selected() -> void:

	var selected_tree_item: TreeItem = _NavTree.get_selected()
	var category_info: Dictionary = selected_tree_item.get_metadata(0)

	if current_category_viewer:
		_display_location.remove_child(current_category_viewer)
		_stored_scenes[category_info["name"]] = current_category_viewer

	if _stored_scenes.has(category_info["name"]):
		current_category_viewer = _stored_scenes[category_info["name"]]
	else:
		current_category_viewer = (category_info["scene"] as PackedScene).instance()

	_display_location.add_child(current_category_viewer)
	emit_signal("nav_item_selected", category_info)

