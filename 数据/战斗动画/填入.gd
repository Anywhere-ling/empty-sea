extends 战斗_动画




func _start() -> void:
	card = data["素材"]
	var new_card:Card = data["card"]
	var life:战斗_life = data["life"]
	var new_pos = new_card.card_sys.get_parent()
	var 场上: = get_场上(new_pos.glo_x, new_pos.y)
	var new_pos_posi:Vector2 = 场上.get_posi()
	
	card.pos_remove_card()
	
	_add_card(card)
	
	card.rotation_degrees = 0
	card.scale = Vector2()
	card.alpha = 0
	var 带拖尾的光球:Node2D = _add_效果("带拖尾的光球")
	add_child(带拖尾的光球)
	带拖尾的光球.posi = card
	if !card.card_sys.appear:
		带拖尾的光球.变灰()
	
	
	await get_tree().create_timer(0.05/speed).timeout

	
	card.tween_kill("位置")
	card.tween_kill("旋转")
	card.tween_kill("缩放")
	emit_可以继续(data["动画index"])
	
	
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("位置", "global_position", new_pos_posi, 0.4/speed)
	await get_tree().create_timer(0.4/speed).timeout
	remove_child(带拖尾的光球)
	带拖尾的光球.queue_free()
	
	new_card.add_card(card)
	emit_动画完成()
	
	_free()
