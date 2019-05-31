extends Reference
class_name TreeItemHelper


static func expand_all_children(tree_item: TreeItem) -> void:

	tree_item.collapsed = false

	var child: TreeItem = tree_item.get_children()
	while child:

		expand_all_children(child)
		child = child.get_next()


static func collapse_all_children(tree_item: TreeItem, collapse_root: bool = true) -> void:

	tree_item.collapsed = collapse_root

	var child: TreeItem = tree_item.get_children()
	while child:

		collapse_all_children(child)
		child = child.get_next()