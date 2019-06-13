extends VBoxContainer

const _ICONS = {
	TYPE_DICTIONARY: preload("res://data_viewer/data_type_icons/dictionary.png"),
	TYPE_ARRAY: preload("res://data_viewer/data_type_icons/array.png"),
	TYPE_BOOL: preload("res://data_viewer/data_type_icons/bool.png"),
	TYPE_REAL: preload("res://data_viewer/data_type_icons/numeral.png"),
	TYPE_STRING: preload("res://data_viewer/data_type_icons/string.png")
}

signal view_changed

export (Color) var group_item_bg_color: Color = Color(0)

onready var _DataTree: Tree = $TreeSplitter/DataTree as Tree

var _json_data


func get_json():
	
	return _json_data


func view_dictionary(data_dict: Dictionary) -> void:

	_json_data = data_dict

	_DataTree.clear()
	_append_dictionary("Dictionary", data_dict)

	emit_signal("view_changed")


func view_array(data_array: Array) -> void:

	_json_data = data_array

	_DataTree.clear()
	_append_array("Array", data_array)

	emit_signal("view_changed")


func _append_dictionary(label: String, data_dict: Dictionary, parent: TreeItem = null) -> void:

	var new_dict: TreeItem = _DataTree.create_item(parent)
	new_dict.set_metadata(0, TYPE_DICTIONARY)

	new_dict.set_text(0, label)
	new_dict.set_icon(0, _ICONS[TYPE_DICTIONARY])

	new_dict.set_selectable(0, false)
	new_dict.set_selectable(1, false)

	var depth: int = TreeItemHelper.tree_depth(new_dict, false)
	new_dict.set_custom_bg_color(0, group_item_bg_color.darkened(0.15 * depth))
	new_dict.set_custom_bg_color(1, group_item_bg_color.darkened(0.15 * depth))

	var keys = data_dict.keys()

	for key in keys:

		var value = data_dict[key]

		match typeof(value):

			TYPE_REAL, TYPE_STRING, TYPE_BOOL:
				_append_item(key, value, new_dict)
			TYPE_DICTIONARY:
				_append_dictionary(key, value, new_dict)
			TYPE_ARRAY:
				_append_array(key, value, new_dict)


func _append_array(label: String, data_array: Array, parent: TreeItem = null) -> void:

	var new_array: TreeItem = _DataTree.create_item(parent)
	new_array.set_metadata(0, TYPE_ARRAY)

	new_array.set_text(0, label)
	new_array.set_icon(0, _ICONS[TYPE_ARRAY])

	new_array.set_selectable(0, false)
	new_array.set_selectable(1, false)

	var depth: int = TreeItemHelper.tree_depth(new_array, false)
	new_array.set_custom_bg_color(0, group_item_bg_color.darkened(0.15 * depth))
	new_array.set_custom_bg_color(1, group_item_bg_color.darkened(0.15 * depth))

	for i in range(data_array.size()):

		var value = data_array[i]

		match typeof(value):

			TYPE_REAL, TYPE_STRING, TYPE_BOOL:
				_append_item(str(i), value, new_array)
			TYPE_DICTIONARY:
				_append_dictionary(str(i), value, new_array)
			TYPE_ARRAY:
				_append_array(str(i), value, new_array)


func _append_item(label: String, value, parent: TreeItem = null) -> void:

	var item_type = typeof(value)
	var new_item: TreeItem = _DataTree.create_item(parent)
	new_item.set_metadata(0, item_type)

	new_item.set_text(0, label)
	new_item.set_icon(0, _ICONS[item_type])
	new_item.set_selectable(0, false)
	new_item.set_text(1, str(value))


func _on_FileNav_file_selected(selected_file: FileSystemItem):

	if !selected_file.is_file():
		return

	_json_data = selected_file.read_as_json()

	if typeof(_json_data) == TYPE_ARRAY:
		view_array(_json_data as Array)
	elif typeof(_json_data) == TYPE_DICTIONARY:
		view_dictionary(_json_data as Dictionary)
	else:
		Log.error("Encountered error when parsing json file '%s'; root data type is not array or dictionary.", [selected_file.path])

