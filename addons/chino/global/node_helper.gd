extends Reference
class_name NodeHelper


static func get_child_of_class(node: Node, name_of_class: String) -> Node:

	var children: Array = node.get_children()

	for child in children:

		if child.get_class() == name_of_class:
			return child

	return null

