extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos_life:战斗_life = data["pos"][0]
	var new_pos:String = data["pos"][1]
	var new_pos_posi:Vector2 = life.get_posi(new_pos)
	var pos:String = card.get_his_pos()
	var pos_posi:Vector2 = life.get_posi(pos)
	
	card.pos_remove_card()
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	if is_方块区(life, pos):
		card.global_position = pos_posi
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.alpha = 0
		card.tween_trans = Tween.TRANS_EXPO
		card.tween动画添加("浮现", "alpha", 1, 0.2/speed)
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2/speed)
		
		await get_tree().create_timer(0.2/speed).timeout
	
	
	
	var 场上: = get_场上(data["pos"][2][0], data["pos"][2][1])
	new_pos_posi = 场上.get_posi()
	场上.add_card(card)
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4/speed)
	card.tween动画添加("旋转", "rotation_degrees", 0, 0.4/speed)
	card.tween动画添加("位置", "global_position", new_pos_posi, 0.4/speed)
	await get_tree().create_timer(0.4/speed).timeout
	
	emit_可以继续(data["动画index"])
	emit_动画完成()
	
	_free()
