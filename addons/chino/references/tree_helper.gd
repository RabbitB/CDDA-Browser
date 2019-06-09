extends Reference
class_name TreeHelper


static func scroll_to_item(tree: Tree, item: TreeItem, select: bool = false, column: int = 0) -> void:

	var item_is_selectable: bool = item.is_selectable(column)
	var previously_selected_item: TreeItem = tree.get_selected()
	var previously_selected_column: int = tree.get_selected_column()

	if !item_is_selectable:
		item.set_selectable(column, true)

	item.select(column)
	tree.ensure_cursor_is_visible()

	if !item_is_selectable:
		item.set_selectable(column, false)

	if !select && previously_selected_item != null:
		item.deselect(column)
		previously_selected_item.select(previously_selected_column)

