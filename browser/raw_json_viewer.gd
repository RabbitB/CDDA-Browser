extends TextEdit


func _on_FileNav_nav_item_selected(selected_item: FileSystemItem) -> void:

	if selected_item.is_file():
		text = selected_item.read_as_text()

