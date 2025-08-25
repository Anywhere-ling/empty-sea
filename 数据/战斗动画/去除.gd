extends 战斗_动画




func _start() -> void:
	card = data["素材"]
	var new_card:Card = data["card"]
	var life:战斗_life = data["life"]
	var pos_life:战斗_life = data["pos"][0]
	var pos:String = new_card.get_pos()
	if len(pos) == 2:
		pos = new_card.get_his_pos()
	var new_pos:String = data["pos"][1]
	var new_pos_posi:Vector2 = pos_life.get_posi(new_pos)
	var y:int = int(pos.erase(3))
	var glo_x:int = int(pos.erase(2))
	var 场上: = get_场上(glo_x, y)
	var pos_posi:Vector2 = 场上.get_posi()
	
	
	card.pos_remove_card()
	
	_add_card(card)
	
	card.rotation_degrees = 0
	card.scale = Vector2()
	card.alpha = 0
	card.global_position = pos_posi
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
	card.tween动画添加("旋转", "rotation_degrees", -90, 0.4/speed)
	card.tween动画添加("位置", "global_position", new_pos_posi, 0.4/speed)
	await get_tree().create_timer(0.4/speed).timeout
	remove_child(带拖尾的光球)
	带拖尾的光球.queue_free()
	
	life.add_card(card, new_pos)
	emit_动画完成()
	
	_free()
