extends Node


@onready var buff系统: Node = $"../单位管理系统/buff系统"
@onready var 回合系统: Node = %回合系统
@onready var 卡牌打出与发动系统: Node = $"../单位管理系统/卡牌打出与发动系统"


signal 数据返回

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

signal 可以继续


func _add_history(data_sys:战斗_单位管理系统.Data_sys, tapy:String, data = null) -> void:
	data_sys.add_history(tapy, 回合系统.turn, 回合系统.period, data)


func 行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#判断
	if card.get_parent().name != "手牌":
		
		event_bus.push_event("战斗_日志记录", [name, "行动打出", [life, card], false])
		return false
	
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	life.cards_pos["行动"].add_card(card)
	
	event_bus.push_event("战斗_日志记录", [name, "行动打出", [life, card], true])
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#buff判断
	buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 非行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#判断
	if card.get_parent().name != "手牌":
		
		event_bus.push_event("战斗_日志记录", [name, "非行动打出", [life, card], false])
		return false
	
	#悬置
	card.get_parent().remove_card(card)
	card.direction = 0
	#选择
	var pos:战斗_单位管理系统.Card_pos_sys
	event_bus.subscribe("战斗_请求选择一格返回", func(a):
		emit_signal("数据返回")
		pos = a
		, 1, true)
	event_bus.push_event("战斗_请求选择一格", [life, life.cards_pos["场上"]])
	await 数据返回
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	卡牌打出与发动系统.发动(card)
	
	event_bus.push_event("战斗_日志记录", [name, "非行动打出", [life, card], true])
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#buff判断
	buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 改变方向(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#判断
	if card.get_parent().name != "场上":
		
		event_bus.push_event("战斗_日志记录", [name, "改变方向", [life, card], false])
		return false
	
	#动画
	await 可以继续
	#后续
	if card.direction == 1:
		card.direction = 0
	elif card.direction == 0:
		card.direction = 1
	
	event_bus.push_event("战斗_日志记录", [name, "改变方向", [life, card], true])
	_add_history(card, "改变方向")
	
	#buff判断
	buff系统.单位与全部buff判断("改变方向", [null, life, card])
	
	return true


func 反转(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await 可以继续
	#后续
	if card.appear == 0:
		card.face_up()
	else:
		card.face_down()
	
	event_bus.push_event("战斗_日志记录", [name, "反转", [life, card], true])
	_add_history(card, "反转")
	
	#buff判断
	buff系统.单位与全部buff判断("反转", [null, life, card])
	
	return true


func 加入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#判断
	if card.get_parent() == pos:
		
		event_bus.push_event("战斗_日志记录", [name, "加入", [life, card, pos], false])
		return false
	
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	
	event_bus.push_event("战斗_日志记录", [name, "加入", [life, card, pos], true])
	_add_history(life, "加入", card)
	_add_history(card, "加入")
	
	#buff判断
	buff系统.单位与全部buff判断("加入", [null, life, card])
	
	return true


func 抽牌(life:战斗_单位管理系统.Life_sys) -> bool:
	#判断
	if life.cards_pos["白区"].cards == []:
		
		event_bus.push_event("战斗_日志记录", [name, "抽牌", [life], false])
		return false
	
	#悬置
	var card:战斗_单位管理系统.Card_sys = life.cards_pos["白区"].cards[0]
	card.get_parent().remove_card(card)
	
	#动画
	
	await 可以继续
	
	#后续
	life.cards_pos["手牌"].add_card(card)
	
	event_bus.push_event("战斗_日志记录", [name, "抽牌", [life], true])
	_add_history(life, "抽牌", card)
	_add_history(card, "抽牌")
	
	buff系统.单位与全部buff判断("抽牌", [null, life, card])
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	event_bus.push_event("战斗_释放卡牌", [life, card])
	
	event_bus.push_event("战斗_日志记录", [name, "加入", [life, card], true])
	_add_history(life, "抽牌", card)
	_add_history(card, "消耗")
	
	#buff判断
	buff系统.单位与全部buff判断("加入", [null, life, card])
	
	return true
