extends 战斗_动画




func _start() -> void:
	card = data["card"]
	
	card.tween_ease = Tween.EASE_IN
	card.tween_trans = Tween.TRANS_EXPO
	card.tween动画添加("缩放", "scale", Vector2(1,1), 0.2)
	
	var mat: = ShaderMaterial.new()
	mat.shader = _add_shader("灰色")
	card.图片.material = mat
	
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("flash", 0.8)
	
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("flash", 0)
	
	await get_tree().create_timer(0.1).timeout
	
	
	card.tween_trans = Tween.TRANS_QUAD
	card.tween动画添加("缩放", "scale", Vector2(0.7,0.7), 0.4)
	
	await get_tree().create_timer(0.2).timeout
	
	card.图片.material = null
	
	await get_tree().create_timer(0.6).timeout
	
	emit_可以继续()
	emit_动画完成()
	
	_free()
