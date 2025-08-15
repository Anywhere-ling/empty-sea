extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos_life:战斗_life = data["pos"][0]
	var new_pos:String = data["pos"][1]
	var new_pos_posi:Vector2 = life.get_posi(new_pos)
	var pos:String = card.get_his_pos()
	var pos_posi:Vector2 = life.get_posi(pos)
	
	life.remove_card(card, pos)
	
	_add_card(card)
	
	card.tween_ease = Tween.EASE_OUT
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.global_position = pos_posi
		card.rotation_degrees = -90
		card.scale = Vector2()
		card.modulate = Color(1,1,1,0)
		card.tween_trans = Tween.TRANS_CUBIC
		card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.2)
		card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.2)
		
		await get_tree().create_timer(0.2).timeout
	
	
	
	pos_life.add_card(card, new_pos)
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4)
	card.tween动画添加("旋转", "rotation_degrees", 0, 0.4)
	card.tween动画添加("位置", "global_position", new_pos_posi, 0.4)
	await get_tree().create_timer(0.4).timeout
	
	emit_可以继续()
	emit_动画完成()
	
	_free()
