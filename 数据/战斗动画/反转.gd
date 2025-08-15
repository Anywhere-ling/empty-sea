extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var pos:String = card.get_pos()
	
	
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.emit_signal("图片或文字改变", "appear")
		emit_可以继续()
		emit_动画完成()
	else :
		var vec2:Vector2 = Vector2(-80, 0)
		vec2 = vec2.rotated(card.第二层.rotation)
		card.tween_trans = Tween.TRANS_QUAD
		card.tween_ease = Tween.EASE_IN
		card.tween动画添加_第二层("位置", "position", vec2, 0.3)
		await get_tree().create_timer(0.1).timeout
		card.tween动画添加_第二层("浮现", "modulate", Color(1,1,1,0), 0.2)
		await get_tree().create_timer(0.2).timeout
		card.emit_signal("图片或文字改变")
		emit_可以继续()
		card.tween_ease = Tween.EASE_OUT
		card.tween动画添加_第二层("位置", "position", Vector2(0, 0), 0.3)
		await get_tree().create_timer(0.1).timeout
		card.tween动画添加_第二层("浮现", "modulate", Color(1,1,1,1), 0.2)
		await get_tree().create_timer(0.2).timeout
		
		emit_动画完成()
	
	_free()
