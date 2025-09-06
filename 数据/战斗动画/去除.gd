extends 战斗_动画




func _start() -> void:
	card = data["源"]
	var life:战斗_life = data["life"]
	var new_pos:Node = data["pos"]
	var new_card:Card = data["card"]
	
	
	var pos: = card.pos_remove_card()
	
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
	card.emit_signal("源数量改变")
	
	new_pos.add_card(card)
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("旋转", "rotation_degrees", -90, 0.4/speed)
	card.tween动画添加("位置", "position", Vector2(0,0), 0.4/speed)
	await get_tree().create_timer(0.4/speed).timeout
	remove_child(带拖尾的光球)
	带拖尾的光球.queue_free()
	
	
	emit_动画完成()
	
	_free()
