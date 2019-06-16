extends TabContainer

onready var _ContextTabs: TabContainer = $"../ContextTabs"


func _on_tab_changed(tab: int) -> void:

	var tab_node: Control = get_tab_control(tab)

	match tab_node.name:

		"Raw File", "JSON":
			_ContextTabs.current_tab = 0
		"Game Data":
			_ContextTabs.current_tab = 1
		_:
			_ContextTabs.current_tab = 0

