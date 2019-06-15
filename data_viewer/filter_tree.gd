extends Tree

const DataViewer: Script = preload("res://data_viewer/data_viewer.gd")
const DataTree: Script = preload("res://data_viewer/data_tree.gd")

export (Color) var group_item_bg_color: Color = Color(0)

onready var _DataViewer: DataViewer = $"../.." as DataViewer
onready var _DataTree: Tree = $"../DataTree" as DataTree

var _table_of_contents: TreeItem
var _filters: TreeItem
var _sorted: TreeItem


func crawl_data_tree() -> void:

	clear()

	var root = create_item()
	root.set_text(0, "root")

	_filters = _create_group("Filters", root)
	_sorted = _create_group("Sorted", root)
	_table_of_contents = _create_group("Table of Contents", root)

	_crawl_container(_DataTree.get_root(), _table_of_contents)


func _crawl_container(container_to_crawl: TreeItem, parent: TreeItem = null):

	var new_container: TreeItem = create_item(parent)
	new_container.set_text(0, container_to_crawl.get_text(0))
	new_container.set_icon(0, container_to_crawl.get_icon(0))
	new_container.set_metadata(0, { "linked_item": container_to_crawl })

	var child: TreeItem = container_to_crawl.get_children()

	while child:

		var child_type: int = child.get_metadata(0)["type"]

		if child_type == TYPE_DICTIONARY || child_type == TYPE_ARRAY:
			_crawl_container(child, new_container)

		child = child.get_next()


func _get_items_with_comparable_path(tree_item: TreeItem) -> Array:

	var comparable_path: Array = _DataTree.get_comparable_path(tree_item)

	var comparable_items: Array = [_DataTree.get_root()]
	var matching_items: Array = []

	for segment in comparable_path:

		for item in comparable_items:
			matching_items += TreeItemHelper.filter_children_custom(item, segment, self, "_filter_tree_item")

		comparable_items = matching_items
		matching_items = []

	return comparable_items


func _filter_tree_item(item: TreeItem, filter) -> bool:

	var parent: TreeItem = item.get_parent()
	var parent_metadata: Dictionary = parent.get_metadata(0) if parent else null

	if filter == "array_item" && parent_metadata && parent_metadata.get("type") == TYPE_ARRAY:
		return true

	return item.get_text(0) == filter


func _sort_tree_item(a: TreeItem, b: TreeItem) -> bool:

	var data_type: int = a.get_metadata(0)["type"]

	if data_type == TYPE_REAL:
		return float(a.get_text(1)) < float(b.get_text(1))
	elif data_type == TYPE_BOOL:
		return bool(a.get_text(1)) < bool(b.get_text(1))
	else:
		return a.get_text(1) < b.get_text(1)

	return false


func _create_group(name: String, parent: TreeItem) -> TreeItem:

	var new_group = create_item(parent)
	new_group.set_text(0, name)
	new_group.set_custom_bg_color(0, group_item_bg_color)
	new_group.set_selectable(0, false)

	return new_group


func _get_group_name(tree_item: TreeItem) -> String:

	var name: String = ""
	var comparable_path: Array = _DataTree.get_comparable_path(tree_item)

	if comparable_path.size() == 1:
		name = comparable_path[0]
	else:

		for segment in comparable_path:

			if segment == "array_item":
				segment = "[ ]"

			if name.empty():
				name = segment
			else:
				name = "%s»%s" % [name, segment]

	return name


func _get_group_item_name(item: TreeItem) -> String:

	var name: String = "%s (%s)" % [item.get_text(0), item.get_text(1)]
	var parent: TreeItem = item.get_parent()
	var grandparent: TreeItem = parent.get_parent()

	while grandparent:

		name = "%s»%s" % [parent.get_text(0), name]
		parent = grandparent
		grandparent = grandparent.get_parent()

	return name


func _on_DataViewer_view_changed():

	crawl_data_tree()


func _on_item_selected():

	var metadata: Dictionary = get_selected().get_metadata(0)

	if !metadata:
		return

	var linked_item: TreeItem = metadata.get("linked_item")

	if !linked_item:
		return

	TreeHelper.scroll_to_item(_DataTree, linked_item, true, 1, TreeHelper.ScrollPlacement.ON_TOP)


func _on_DataTree_filter_button_pressed(tree_item: TreeItem):

	var filter_group: TreeItem = create_item(_filters)
	filter_group.set_text(0, _get_group_name(tree_item))
	filter_group.add_button(0, preload("res://data_viewer/close.png"))

	var comparable_items: Array = _get_items_with_comparable_path(tree_item)

	for item in comparable_items:

		if !item.get_text(1) == tree_item.get_text(1):
			continue

		var new_filter_entry: TreeItem = create_item(filter_group)
		new_filter_entry.set_text(0, _get_group_item_name(item))
		new_filter_entry.set_metadata(0, { "linked_item": item })


func _on_DataTree_sort_button_pressed(tree_item):

	var sort_group: TreeItem = create_item(_sorted)
	sort_group.set_text(0, _get_group_name(tree_item))
	sort_group.add_button(0, preload("res://data_viewer/close.png"))

	var comparable_items: Array = _get_items_with_comparable_path(tree_item)
	comparable_items.sort_custom(self, "_sort_tree_item")

	for item in comparable_items:

		var new_entry: TreeItem = create_item(sort_group)
		new_entry.set_text(0, _get_group_item_name(item))
		new_entry.set_metadata(0, { "linked_item": item })


func _on_button_pressed(item: TreeItem, column: int, id: int):

#	The only button we have on items in the filter tree, is the remove button.
	item.free()

