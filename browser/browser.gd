extends VBoxContainer

onready var _ExplorerAddressBar: ExplorerAddressBar = $TopBar/ExplorerAddressBar as ExplorerAddressBar

var config_file_path: String = "user://config.ini"
var cdda_install_dir: String


func _ready():

	read_config_file()
	_ExplorerAddressBar.path = cdda_install_dir


func read_config_file() -> void:

	var config_file: ConfigFile = ConfigFile.new()

	var error: int = config_file.load(config_file_path)

	if error:
		Log.error("Encountered error '%s' when loading config file.", [Log.get_error_description(error)])

	cdda_install_dir = config_file.get_value("cdda", "install_dir", OS.get_executable_path().get_base_dir())


func save_config_file() -> void:

	var config_file: ConfigFile = ConfigFile.new()

	config_file.set_value("cdda", "install_dir", cdda_install_dir)
	var error: int = config_file.save(config_file_path)

	if error:
		Log.error("Encountered error '%s' when saving config file.", [Log.get_error_description(error)])


func _on_ExplorerAddressBar_path_changed(path, is_path_valid):

	if is_path_valid:
		cdda_install_dir = path
		save_config_file()

