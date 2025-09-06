extends 战斗_动画




func _start() -> void:
	var life:战斗_life = data["life"]
	
	
	
	var mat: = ShaderMaterial.new()
	mat.shader = _add_shader("灰色")
	life.life图.material = mat
	
	await get_tree().create_timer(0.1/speed).timeout
	mat.set_shader_parameter("flash", 0.8)
	
	await get_tree().create_timer(0.4/speed).timeout
	
	life.life图.material = null
	
	await get_tree().create_timer(0.2/speed).timeout
	
	emit_可以继续(data["动画index"])
	emit_动画完成()
	
	_free()
