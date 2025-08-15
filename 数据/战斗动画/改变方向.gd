extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos:String = card.get_pos()
	
	var ro:int = 0
	if !card.card_sys.direction:
		ro = 90
	
	
	card.tween_ease = Tween.EASE_IN_OUT
	card.tween_trans = Tween.TRANS_QUAD
	if pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.第二层.rotation_degrees = ro
		emit_可以继续()
	else :
		card.tween动画添加_第二层("方向", "rotation_degrees", ro, 0.4)
		await get_tree().create_timer(0.2).timeout
		emit_可以继续()
		await get_tree().create_timer(0.2).timeout
	
	emit_动画完成()
	
	_free()
