extends VBoxContainer

signal nav_content_updated
signal nav_item_selected(selected_item)

onready var _NavTree: Tree = $NavTree as Tree
onready var _SearchBar: LineEdit = $TreeControls/SearchLine as LineEdit
onready var _UpdateDelay: Timer = $UpdateDelay as Timer


func _update_nav() -> bool:
	return true


func _on_SearchLine_text_changed(new_text: String) -> void:
	_UpdateDelay.start()


func _on_UpdateDelay_timeout() -> void:
	_update_nav()


func _on_Tree_item_selected() -> void:
	pass

