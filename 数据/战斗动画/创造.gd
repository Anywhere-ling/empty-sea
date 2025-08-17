extends 战斗_动画




func _start() -> void:
	card = data["card"]
	
	_add_card(card)
	
	card.modulate = Color(1,1,1,0)
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_CUBIC
	card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.5/speed)
	if !card.card_sys.direction:
		card.tween动画添加_第二层("方向", "rotation_degrees", 90, 0.5/speed)
	await get_tree().create_timer(0.7/speed).timeout
	
	
	
	
	emit_可以继续()
	
	emit_动画完成()
	
	_free()
