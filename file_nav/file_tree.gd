extends Tree


func expand_all(tree_item: TreeItem) -> void:

	tree_item.collapsed = false

	var child: TreeItem = tree_item.get_children()
	while child:

		expand_all(child)
		child = child.get_next()


func collapse_all(tree_item: TreeItem, collapse_root: bool = true) -> void:

	tree_item.collapsed = collapse_root

	var child: TreeItem = tree_item.get_children()
	while child:

		collapse_all(child)
		child = child.get_next()


func _on_ExpandAllButton_pressed():

	expand_all(get_root())


func _on_CollapseAllButton_pressed():

	collapse_all(get_root(), false)

