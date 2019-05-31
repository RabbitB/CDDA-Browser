extends Tree


func _on_SortOrder_expand_all_pressed():

	TreeItemHelper.expand_all_children(get_root())


func _on_SortOrder_collapse_all_pressed():

	TreeItemHelper.collapse_all_children(get_root(), false)

