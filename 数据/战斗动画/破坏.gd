extends 战斗_动画




func _start() -> void:
	card = data["card"]
	var life:战斗_life = data["life"]
	var pos:String = card.get_his_pos()
	var pos_posi:Vector2 = life.get_posi(pos)
	
	life.remove_card(card, pos)
	
	_add_card(card)
	
	
	
	card.tween_ease = Tween.EASE_IN
	card.tween_trans = Tween.TRANS_EXPO
	if !pos in ["白区", "绿区", "蓝区" ,"红区"]:
		card.tween动画添加("缩放", "scale", Vector2(0.4,0.4), 0.1/speed)
		card.tween动画添加("旋转", "rotation_degrees", 10, 0.1/speed)
		await get_tree().create_timer(0.1/speed).timeout
		var 破坏碎片:GPUParticles2D = _add_效果("破坏碎片")
		add_child(破坏碎片)
		破坏碎片.global_position = card.global_position
		破坏碎片.restart()
		card.modulate = Color(1,1,1,0)
		card.scale = Vector2()
		await get_tree().create_timer(0.1/speed).timeout
	
	var 带拖尾的光球:Node2D = _add_效果("带拖尾的光球")
	add_child(带拖尾的光球)
	带拖尾的光球.posi = card
	emit_可以继续()
	
	card.tween_ease = Tween.EASE_OUT
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("旋转", "rotation_degrees", -90, 0.4/speed)
	card.tween动画添加("位置", "global_position", life.get_posi("绿区"), 0.4/speed)
	await get_tree().create_timer(0.4/speed).timeout
	remove_child(带拖尾的光球)
	带拖尾的光球.queue_free()
	
	life.add_card(card, "绿区")
	
	emit_动画完成()
	
	_free()
