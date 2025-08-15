extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos:String = "白区"
	var pos_posi:Vector2 = life.get_posi(pos)
	
	card.emit_signal("图片或文字改变", "appear")
	
	life.remove_card(card, pos)
	
	_add_card(card)
	
	
	card.tween_ease = Tween.EASE_OUT
	card.global_position = pos_posi
	card.rotation_degrees = -90
	card.scale = Vector2()
	card.modulate = Color(1,1,1,0)
	card.tween_trans = Tween.TRANS_EXPO
	card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.2)
	card.tween动画添加("缩放", "scale", Vector2(0.5,0.5), 0.2)

	get_tree().create_timer(0.2).timeout.connect(emit_可以继续, 4)
	await get_tree().create_timer(0.2).timeout
	
	
	life.add_card(card, "手牌")
	await get_tree().create_timer(0.4).timeout
	
	
	emit_动画完成()
	
	_free()
