tool
extends Control

export(Vector2) var target_position = Vector2() setget _set_target_position

onready var _Sprite: Sprite = $Node2DContainer/Sprite
onready var _AnimationPlayer: AnimationPlayer = $AnimationPlayer
onready var _Timer: Timer = $Timer


func _set_target_position(pos: Vector2) -> void:

	$Node2DContainer.target_position = pos
	target_position = pos


func wait(for_time: float = 0.0) -> void:

	if for_time:
		_Timer.start(for_time)
	else:
		_Timer.stop()
		_AnimationPlayer.play("waiting")


func stop() -> void:
	_AnimationPlayer.play("inactive")


func _on_Timer_timeout():
	stop()

