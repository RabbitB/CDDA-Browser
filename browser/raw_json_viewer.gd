extends TextEdit


func _on_FileNav_file_selected(selected_file: FileSystemItem):

	if selected_file.is_file():
		text = selected_file.read_as_text()

