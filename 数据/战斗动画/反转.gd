extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var pos:String = card.get_pos()
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.emit_signal("图片或文字改变")
		emit_可以继续()
		emit_动画完成()
	else :
		card.第二层.position.y = card.图片.size.y
		card.tween_ease = Tween.EASE_IN_OUT
		card.tween_trans = Tween.TRANS_EXPO
		var tween: = card.tween动画添加_第二层("反转", "rotation_degrees", card.第二层.rotation_degrees + 360, 0.4)
		card.tween_ease = Tween.EASE_IN
		card.tween动画添加("浮现", "modulate", Color(1,1,1,0), 0.1)
		await get_tree().create_timer(0.2).timeout
		card.emit_signal("图片或文字改变")
		emit_可以继续()
		await get_tree().create_timer(0.1).timeout
		card.tween_ease = Tween.EASE_OUT
		card.tween动画添加("浮现", "modulate", Color(1,1,1,1), 0.1)
		await tween.finished
		card.第二层.position.y = 0
		card.第二层.rotation_degrees = 0
		emit_动画完成()
	
	_free()
