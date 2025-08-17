extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos:String = card.get_his_pos()
	var pos_posi:Vector2 = life.get_posi(pos)
	
	life.remove_card(card, pos)
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_EXPO
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.global_position = pos_posi
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.modulate = Color(1,1,1,1)
		card.tween_trans = Tween.TRANS_EXPO
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2/speed)
		await get_tree().create_timer(0.2/speed).timeout
	
	card.tween动画添加("浮现", "modulate", Color(1,1,1,0), 0.2/speed)
		
	await get_tree().create_timer(0.1/speed).timeout
	emit_可以继续()
	await get_tree().create_timer(0.1/speed).timeout
	card.free_card()
	emit_动画完成()
	
	_free()
