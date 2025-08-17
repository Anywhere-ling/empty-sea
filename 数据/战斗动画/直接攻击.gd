extends 战斗_动画




func _start() -> void:
	card = data["card"]
	
	card.tween_ease = Tween.EASE_IN
	card.tween_trans = Tween.TRANS_ELASTIC
	card.tween动画添加_第二层("位置", "position", Vector2(0, -550), 0.3/speed)
	
	await get_tree().create_timer(0.3/speed).timeout
	
	
	card.tween_ease = Tween.EASE_IN
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加_第二层("位置", "position", Vector2(0,0), 0.4/speed)
	
	await get_tree().create_timer(0.1/speed).timeout
	emit_可以继续()
	await get_tree().create_timer(0.2/speed).timeout
	emit_动画完成()
	
	_free()
