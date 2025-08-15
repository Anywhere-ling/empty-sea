extends 战斗_动画




func _start() -> void:
	card = data["card"]
	
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_EXPO
	card.tween动画添加("缩放", "scale", Vector2(1,1), 0.4)
	
	await get_tree().create_timer(0.6).timeout
	emit_可以继续()
	
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4)
	
	await get_tree().create_timer(0.4).timeout
	emit_动画完成()
	
	_free()
