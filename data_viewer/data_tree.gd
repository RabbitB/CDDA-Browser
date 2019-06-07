extends Tree

signal sort_button_pressed(tree_item, sorted_key)
signal search_button_pressed(tree_item, searched_key, searched_value)

var _previous_selection: TreeItem


func scroll_to_item(item: TreeItem, select: bool = false, column: int = 0) -> void:

	var item_is_selectable: bool = item.is_selectable(column)
	var previously_selected_item: TreeItem = get_selected()
	var previously_selected_column: int = get_selected_column()

	if !item_is_selectable:
		item.set_selectable(column, true)

	item.select(column)
	ensure_cursor_is_visible()

	if !item_is_selectable:
		item.set_selectable(column, false)

	if !select && previously_selected_item != null:
		item.deselect(column)
		previously_selected_item.select(previously_selected_column)


func _on_SortOrder_expand_all_pressed() -> void:

	TreeItemHelper.expand_all_children(get_root())


func _on_SortOrder_collapse_all_pressed() -> void:

	TreeItemHelper.collapse_all_children(get_root(), false)


func _on_DataTree_item_selected() -> void:

	if _previous_selection:
		_previous_selection.erase_button(0, 0)
		_previous_selection.erase_button(1, 0)

	var selected_item: TreeItem = get_selected()

	if selected_item.get_children() == null:

		selected_item.add_button(0, preload("res://data_viewer/sort.png"), -1, false, "Sort entries by this key")
		selected_item.add_button(1, preload("res://data_viewer/search.png"), -1, false, "Search entries for matching value")
		_previous_selection = selected_item


func _on_DataTree_nothing_selected() -> void:

	if _previous_selection:
		_previous_selection.erase_button(0, 0)
		_previous_selection.erase_button(1, 0)

	_previous_selection = null


func _on_DataViewer_view_changed() -> void:

	_previous_selection = null
	scroll_to_item(get_root(), false)


func _on_DataTree_button_pressed(item: TreeItem, column: int, id: int) -> void:

	if column == 0:
		emit_signal("sort_button_pressed", item, item.get_text(0))
	elif column == 1:
		emit_signal("search_button_pressed", item, item.get_text(0), item.get_text(1))

