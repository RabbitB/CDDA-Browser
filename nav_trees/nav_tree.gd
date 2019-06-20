extends Tree


func _on_ExpandAllButton_pressed():

	TreeItemHelper.expand_all_children(get_root())


func _on_CollapseAllButton_pressed():

	TreeItemHelper.collapse_all_children(get_root(), false)

