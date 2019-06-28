extends VBoxContainer

const _ICONS = {
	TYPE_DICTIONARY: preload("res://json_viewer/data_type_icons/dictionary.png"),
	TYPE_ARRAY: preload("res://json_viewer/data_type_icons/array.png"),
	TYPE_BOOL: preload("res://json_viewer/data_type_icons/bool.png"),
	TYPE_REAL: preload("res://json_viewer/data_type_icons/numeral.png"),
	TYPE_STRING: preload("res://json_viewer/data_type_icons/string.png")
}

signal started_loading_view
signal finished_loading_view

export (Color) var group_item_bg_color: Color = Color(0)

onready var _JsonTree: Tree = $TreeSplitter/Json/Tree as Tree

var _json_data

var _loaded: bool = false
var _abort_loading: bool = false

var _loading_thread: Thread = Thread.new()
var _loading_mutex: Mutex = Mutex.new()


func _threaded_append_json_collection(args: Dictionary) -> void:

	_loading_mutex.lock()
	_loaded = false
	_abort_loading = false
	_loading_mutex.unlock()

	_append_json_collection(args["label"], args["data"], args.get("parent", null))

	_loading_mutex.lock()
	_loaded = true
	_abort_loading = false
	_loading_mutex.unlock()


func _append_json_collection(label: String, data, parent: TreeItem = null) -> void:

	var local_abort: bool = false

	_loading_mutex.lock()
	local_abort = _abort_loading
	_loading_mutex.unlock()

	if local_abort:
		return

	var data_type: int = typeof(data)
	var new_entry: TreeItem = _create_tree_entry(label, data_type, parent)

	var iterator_group = data.keys() if data_type == TYPE_DICTIONARY else range(data.size())
	for iter in iterator_group:

		var value = data[iter]

		match typeof(value):

			TYPE_REAL, TYPE_STRING, TYPE_BOOL:
				_append_json_value(str(iter), value, new_entry)
			TYPE_DICTIONARY, TYPE_ARRAY:
				_append_json_collection(str(iter), value, new_entry)


func _append_json_value(label: String, value, parent: TreeItem = null) -> void:

	var new_item: TreeItem = _create_tree_entry(label, typeof(value), parent)
	new_item.set_text(1, str(value))


func _create_tree_entry(label: String, data_type: int, parent: TreeItem = null) -> TreeItem:

	var new_entry: TreeItem = _JsonTree.create_item(parent)
	new_entry.set_metadata(0, { "type": data_type })

	new_entry.set_text(0, label)
	new_entry.set_icon(0, _ICONS[data_type])

	new_entry.set_selectable(0, false)

	if data_type == TYPE_DICTIONARY || data_type == TYPE_ARRAY:

		new_entry.set_selectable(1, false)

		var depth: int = TreeItemHelper.tree_depth(new_entry, false)
		var darkened_color = group_item_bg_color.darkened(0.15 * depth)
		new_entry.set_custom_bg_color(0, darkened_color)
		new_entry.set_custom_bg_color(1, darkened_color)

	return new_entry


func get_json():

	return _json_data


func view_json_collection(data) -> void:

	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "busy_indicators", "wait")
	_JsonTree.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_JsonTree.self_modulate = Color(1.0, 1.0, 1.0, 0.4)
	
	emit_signal("started_loading_view")

	_json_data = data
	_JsonTree.clear()

	_loading_thread.start(self, "_threaded_append_json_collection", { "label": "[ROOT]", "data": data })

	var local_loaded: bool = false
	while !local_loaded:
		yield(get_tree(), "idle_frame")

		_loading_mutex.lock()
		local_loaded = _loaded
		_loading_mutex.unlock()

	_loading_thread.wait_to_finish()

	_JsonTree.self_modulate = Color(1.0, 1.0, 1.0, 1.0)
	_JsonTree.mouse_filter = Control.MOUSE_FILTER_STOP
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, "busy_indicators", "stop")

	emit_signal("finished_loading_view")


func _on_FileNav_nav_item_selected(selected_item: FileSystemItem) -> void:

	if !selected_item.is_file():
		return

	#	If the user has decided to click on another nav item while we're still loading, we need to abort
	#	the loading process and immediatly start loading the new nav item data.
	if _loading_thread.is_active():

		_loading_mutex.lock()
		_abort_loading = true
		_loading_mutex.unlock()

		_loading_thread.wait_to_finish()

	_json_data = selected_item.read_as_json()
	var data_type = typeof(_json_data)

	if data_type == TYPE_ARRAY || data_type == TYPE_DICTIONARY:
		view_json_collection(_json_data)
	else:
		Log.error("Encountered error when parsing json file '%s'; root data type is not array or dictionary.", [selected_item.path])

