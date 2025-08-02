extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var new_pos:String = data["pos"]
	var new_pos_posi:Vector2 = life.get_posi(new_pos)
	var pos:String = card.get_pos()
	var pos_posi:Vector2 = life.get_posi(pos)
	
	card.set_glo()
	life.remove_card(card, pos)
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.global_position = pos_posi
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.modulate = Color(1,1,1,0)
		card.tween_trans = Tween.TRANS_EXPO
		card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.2)
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2)
		
		await get_tree().create_timer(0.2).timeout
	
	
	emit_可以继续()
	
	
	
	if new_pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.tween_trans = Tween.TRANS_QUAD
		card.tween动画添加("旋转", "rotation_degrees", -90, 0.4)
		card.tween动画添加("位置", "global_position", new_pos_posi, 0.4)
		await get_tree().create_timer(0.4).timeout
		card.tween_trans = Tween.TRANS_EXPO
		card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.2)
		card.tween动画添加("缩放", "scale", Vector2(), 0.2)
		await get_tree().create_timer(0.2).timeout
		life.add_card(card, new_pos)
		
		
	elif new_pos == "手牌":
		life.add_card(card, new_pos)
		await get_tree().create_timer(0.4).timeout
	
	elif new_pos == "行动":
		card.tween_trans = Tween.TRANS_QUAD
		life.add_card(card, new_pos)
		await get_tree().create_timer(0.4).timeout
	
	elif new_pos in ["场地0", "场地1", "场地2", "场地3", "场地4", "场地5"]:
		card.set_相对旋转中心(Vector2(0.5,0.5))
		card.tween_trans = Tween.TRANS_QUAD
		card.tween动画添加("旋转", "rotation_degrees", 0, 0.4)
		card.tween动画添加("位置", "global_position", new_pos_posi, 0.4)
		await get_tree().create_timer(0.4).timeout
	
	emit_动画完成()
	
	_free()
