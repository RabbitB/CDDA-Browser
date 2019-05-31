extends HBoxContainer

signal expand_all_pressed
signal collapse_all_pressed


func _on_ExpandAllButton_pressed():
	emit_signal("expand_all_pressed")


func _on_CollapseAllButton_pressed():
	emit_signal("collapse_all_pressed")

