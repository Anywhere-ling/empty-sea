extends 战斗_动画




func _start() -> void:
	var 动画1:战斗_动画 = get_parent().create_动画("非行动打出", data)
	动画1.start()
	await 动画1.可以继续
	
	var 动画2:战斗_动画 = get_parent().create_动画("场上发动", data)
	动画2.start()
	await 动画2.可以继续
	
	
	emit_可以继续()
	
	emit_动画完成()
	
	_free()
