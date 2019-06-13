extends Tree

signal sort_button_pressed(tree_item, sorted_key)
signal search_button_pressed(tree_item, searched_key, searched_value)

var _wr_previous_selection: WeakRef


static func get_comparable_path(tree_item: TreeItem) -> Array:

	var comparable_path: Array = []
	var parent: TreeItem = tree_item.get_parent()

	if !parent:
		return [tree_item.get_text(0)]

	while parent:

		if parent.get_metadata(0) == TYPE_ARRAY:
			comparable_path.push_front("array_item")
		else:
			comparable_path.push_front(tree_item.get_text(0))

		parent = tree_item.get_parent()

	return comparable_path


func _on_SortOrder_expand_all_pressed() -> void:

	TreeItemHelper.expand_all_children(get_root())


func _on_SortOrder_collapse_all_pressed() -> void:

	TreeItemHelper.collapse_all_children(get_root(), false)


func _on_DataTree_item_selected() -> void:

	var _previous_selection: TreeItem = _wr_previous_selection.get_ref() if _wr_previous_selection else null

	if _previous_selection:

			_previous_selection.erase_button(0, 0)
			_previous_selection.erase_button(1, 0)

	var selected_item: TreeItem = get_selected()

	if selected_item.get_children() == null:

		selected_item.add_button(0, preload("res://data_viewer/sort.png"), -1, false, "Sort entries by this key")
		selected_item.add_button(1, preload("res://data_viewer/search.png"), -1, false, "Search entries for matching value")
		_wr_previous_selection = weakref(selected_item)


func _on_DataTree_nothing_selected() -> void:

	var _previous_selection: TreeItem = _wr_previous_selection.get_ref() if _wr_previous_selection else null

	if _previous_selection:
		_previous_selection.erase_button(0, 0)
		_previous_selection.erase_button(1, 0)

	_wr_previous_selection = null


func _on_DataViewer_view_changed() -> void:

	_wr_previous_selection = null
	TreeHelper.scroll_to_item(self, get_root(), false)


func _on_DataTree_button_pressed(item: TreeItem, column: int, id: int) -> void:

	if column == 0:
		emit_signal("sort_button_pressed", item, item.get_text(0))
	elif column == 1:
		emit_signal("search_button_pressed", item, item.get_text(0), item.get_text(1))

