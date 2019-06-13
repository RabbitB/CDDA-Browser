extends Tree

const DataViewer: Script = preload("res://data_viewer/data_viewer.gd")

onready var _DataViewer: DataViewer = $"../.." as DataViewer
onready var _DataTree: Tree = $"../DataTree" as Tree


func crawl_data_tree() -> void:

	clear()
	var root = create_item()
	root.set_text(0, "root")

	_crawl_container(_DataTree.get_root())


func _crawl_container(container_to_crawl: TreeItem, parent: TreeItem = null):

	var new_container: TreeItem = create_item(parent)
	new_container.set_text(0, container_to_crawl.get_text(0))
	new_container.set_icon(0, container_to_crawl.get_icon(0))
	new_container.set_metadata(0, { "linked_item": container_to_crawl })

	var child: TreeItem = container_to_crawl.get_children()

	while child:

		if child.get_metadata(0) == TYPE_DICTIONARY || child.get_metadata(0) == TYPE_ARRAY:
			_crawl_container(child, new_container)

		child = child.get_next()


func _append_dictionary(label: String, data_dict: Dictionary, parent: TreeItem = null) -> void:

	var new_dict = create_item(parent)


func _on_DataViewer_view_changed():

	crawl_data_tree()


func _on_item_selected():

	TreeHelper.scroll_to_item(_DataTree, get_selected().get_metadata(0)["linked_item"], true, 1, TreeHelper.ScrollPlacement.ON_TOP)

