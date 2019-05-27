extends HBoxContainer

signal path_changed(path, is_path_valid)

export (String) var placeholder_text: String = "" setget _set_placeholder_text

onready var BrowseFileDialog: FileDialog = $FileDialog as FileDialog
onready var AddressLineEdit: LineEdit = $AddressLineEdit as LineEdit

var path: String setget _set_path, _get_path

onready var _is_ready: bool = true
var _directory: FileSystemItem = FileSystemItem.new()


func _set_placeholder_text(new_placeholder: String) -> void:

	placeholder_text = new_placeholder

	if _is_ready:
		AddressLineEdit.placeholder_text = placeholder_text


func _set_path(new_path: String) -> void:

	update_path(new_path, true)


func _get_path() -> String:

	return AddressLineEdit.text


func _ready() -> void:

	self.placeholder_text = placeholder_text
	update_path(OS.get_executable_path().get_base_dir(), true)


func update_path(new_path: String, update_ui_text: bool) -> void:

	if update_ui_text: AddressLineEdit.text = new_path

	if is_path_valid():

		_directory.path = self.path

		if _directory.is_valid_directory():
			BrowseFileDialog.current_dir = self.path

	emit_signal("path_changed", new_path, is_path_valid())


func get_directory() -> FileSystemItem:

	var directory: FileSystemItem = FileSystemItem.new()
	directory.path = path

	return directory if is_path_valid() && directory.is_valid_directory() else null


func get_active_path() -> String:

	return _directory.path


func is_path_valid(a_path: String = "") -> bool:

	if a_path.empty():
		a_path = self.path

	return _directory.is_directory(a_path) && a_path.is_abs_path()


func _on_AddressLineEdit_text_changed(new_text: String) -> void:

	update_path(new_text, false)


func _on_UpDirButton_pressed() -> void:

	if is_path_valid() && _directory.is_valid_directory():
		_directory = _directory.get_parent()

	update_path(_directory.path, true)


func _on_BrowseButton_pressed() -> void:

	var file_dialog_min_size: Vector2 = get_viewport().size - Vector2(50, 75)
	BrowseFileDialog.popup_centered(file_dialog_min_size)


func _on_FileDialog_dir_selected(dir_path: String) -> void:

	update_path(dir_path, true)

