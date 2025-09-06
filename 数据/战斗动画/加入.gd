extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var new_pos:Node = data["pos"]
	
	
	var pos: = card.pos_remove_card()
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	if is_方块区(pos):
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.alpha = 0.0
		card.tween_trans = Tween.TRANS_CUBIC
		card.tween动画添加("浮现", "alpha", 1, 0.2/speed)
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2/speed)
		
		await get_tree().create_timer(0.1/speed).timeout
	else:
		card.tween_kill("位置")
		card.tween_kill("旋转")
		card.tween_kill("缩放")
	
	
	await get_tree().create_timer(0.1/speed).timeout
	emit_可以继续(data["动画index"])
	
	if is_方块区(new_pos):
		new_pos.add_card(card)
		card.tween_trans = Tween.TRANS_QUAD
		card.tween动画添加("旋转", "rotation_degrees", -90, 0.4/speed)
		card.tween动画添加("位置", "position", Vector2(0,0), 0.4/speed)
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4/speed)
		await get_tree().create_timer(0.2/speed).timeout
		await get_tree().create_timer(0.2/speed).timeout
		card.tween_trans = Tween.TRANS_CUBIC
		card.tween动画添加("浮现", "alpha", 0, 0.2/speed)
		card.tween动画添加("缩放", "scale", Vector2(), 0.2/speed)
		await get_tree().create_timer(0.2/speed).timeout
		
		
		
	elif new_pos.get_pos_nam() == "手牌":
		new_pos.add_card(card)
		await get_tree().create_timer(0.4/speed).timeout
	
	elif new_pos.get_pos_nam() == "行动":
		new_pos.add_card(card)
		card.tween_trans = Tween.TRANS_QUAD
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4/speed)
		card.tween动画添加("旋转", "rotation_degrees", 0, 0.4/speed)
		card.tween动画添加("位置", "position", Vector2(0,0), 0.4/speed)
		await get_tree().create_timer(0.4/speed).timeout
	
	elif new_pos.get_pos_nam() in ["场上"]:
		new_pos.add_card(card)
		card.tween_trans = Tween.TRANS_QUAD
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4/speed)
		card.tween动画添加("旋转", "rotation_degrees", 0, 0.4/speed)
		card.tween动画添加("位置", "position", Vector2(0,0), 0.4/speed)
		await get_tree().create_timer(0.4/speed).timeout
	
	emit_动画完成()
	
	_free()
