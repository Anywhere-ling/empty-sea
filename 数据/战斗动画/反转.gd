extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos:String = card.get_pos()
	
	
	if is_方块区(life, pos):
		card.emit_signal("图片或文字改变", "appear")
		emit_可以继续(data["动画index"])
		emit_动画完成()
	else :
		var vec2:Vector2 = Vector2(-80, 0)
		vec2 = vec2.rotated(card.第二层.rotation)
		card.tween_trans = Tween.TRANS_QUAD
		card.tween_ease = Tween.EASE_IN
		card.tween动画添加_第二层("位置", "position", vec2, 0.3/speed)
		await get_tree().create_timer(0.1/speed).timeout
		card.tween动画添加_第二层("浮现", "alpha", 0, 0.2/speed)
		await get_tree().create_timer(0.2/speed).timeout
		card.emit_signal("图片或文字改变")
		emit_可以继续(data["动画index"])
		card.tween_ease = Tween.EASE_OUT
		card.tween动画添加_第二层("位置", "position", Vector2(0, 0), 0.3/speed)
		await get_tree().create_timer(0.1/speed).timeout
		card.tween动画添加_第二层("浮现", "alpha", 1, 0.2/speed)
		await get_tree().create_timer(0.2/speed).timeout
		
		emit_动画完成()
	
	_free()
