extends Tree

var _previous_selection: TreeItem


func _on_SortOrder_expand_all_pressed():

	TreeItemHelper.expand_all_children(get_root())


func _on_SortOrder_collapse_all_pressed():

	TreeItemHelper.collapse_all_children(get_root(), false)


func _on_DataTree_item_selected():

	if _previous_selection:
		_previous_selection.erase_button(1, 0)

	get_selected().add_button(1, preload("res://data_viewer/search.png"), -1, false, "Search for matching entries")
	_previous_selection = get_selected()


func _on_DataTree_nothing_selected():

	if _previous_selection:
		_previous_selection.erase_button(1, 0)

	_previous_selection = null

