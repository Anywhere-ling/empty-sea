extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	
	var pos:Node = card.pos_remove_card()
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_EXPO
	if is_方块区(pos):
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.alpha = 1
		card.tween_trans = Tween.TRANS_EXPO
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2/speed)
		await get_tree().create_timer(0.2/speed).timeout
	
	card.tween动画添加("浮现", "alpha", 0, 0.2/speed)
		
	await get_tree().create_timer(0.1/speed).timeout
	emit_可以继续(data["动画index"])
	await get_tree().create_timer(0.1/speed).timeout
	card.free_card()
	emit_动画完成()
	
	_free()
