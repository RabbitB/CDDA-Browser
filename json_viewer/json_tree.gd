extends Tree

signal sort_button_pressed(tree_item)
signal filter_button_pressed(tree_item)

var _items_with_buttons: Array


static func get_comparable_path(tree_item: TreeItem) -> Array:

	var comparable_path: Array = []
	var parent: TreeItem = tree_item.get_parent()

	if !parent:
		return [tree_item.get_text(0)]

	while parent:

		if parent.get_metadata(0)["type"] == TYPE_ARRAY:
			comparable_path.push_front("array_item")
		else:
			comparable_path.push_front(tree_item.get_text(0))

		tree_item = parent
		parent = tree_item.get_parent()

	return comparable_path


func _add_buttons_to_item(tree_item: TreeItem) -> void:

	var item_type: int = tree_item.get_metadata(0)["type"]
	if item_type == TYPE_DICTIONARY || item_type == TYPE_ARRAY || tree_item.get_children() != null:
		return

	tree_item.add_button(0, preload("res://json_viewer/button_icons/sort.png"), -1, false, "Sort entries by this key")
	tree_item.add_button(1, preload("res://json_viewer/button_icons/search.png"), -1, false, "Filter entries by this value")

	_items_with_buttons.append(weakref(tree_item))


func _remove_buttons_from_item(tree_item: TreeItem) -> void:

	var button_count_column_0: int = tree_item.get_button_count(0)
	var button_count_column_1: int = tree_item.get_button_count(1)

	for button_i in button_count_column_0:
		tree_item.erase_button(0, button_i)

	for button_i in button_count_column_1:
		tree_item.erase_button(1, button_i)


func _clear_all_buttons() -> void:

	for item_wr in _items_with_buttons:

		var item: TreeItem = item_wr.get_ref()

		if item:
			_remove_buttons_from_item(item)

	_items_with_buttons.clear()


func _on_SortOrder_expand_all_pressed() -> void:

	TreeItemHelper.expand_all_children(get_root())


func _on_SortOrder_collapse_all_pressed() -> void:

	TreeItemHelper.collapse_all_children(get_root(), false)


func _on_JsonTree_item_selected() -> void:

	_clear_all_buttons()

	var selected_item: TreeItem = get_selected()
	_add_buttons_to_item(selected_item)


func _on_JsonTree_nothing_selected() -> void:

	_clear_all_buttons()


func _on_JsonViewer_view_changed() -> void:

	_clear_all_buttons()
	TreeHelper.scroll_to_top(self)


func _on_JsonTree_button_pressed(item: TreeItem, column: int, id: int) -> void:

	if column == 0:
		emit_signal("sort_button_pressed", item)
	elif column == 1:
		emit_signal("filter_button_pressed", item)

