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


static func tree_depth(tree_item: TreeItem, calculate_from_root: bool = false) -> int:

	var depth: int = 0
	var current_parent = tree_item.get_parent()

	while current_parent:

		depth += 1
		current_parent = current_parent.get_parent()

	if depth > 0 && !calculate_from_root:
		depth -= 1

	return depth

