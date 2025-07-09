extends Node


@onready var buff系统: Node = $"../单位管理系统/buff系统"
@onready var 回合系统: Node = %回合系统
@onready var 卡牌打出与发动系统: Node = $"../单位管理系统/卡牌打出与发动系统"
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统
@onready var 释放与源: Node = $"../释放与源"



var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

signal 可以继续


func _add_history(data_sys:战斗_单位管理系统.Data_sys, tapy:String, data = null) -> void:
	data_sys.add_history(tapy, 回合系统.turn, 回合系统.period, data)


func 加入连锁的动画(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, speed:int) -> bool:
	#动画
	await 可以继续
	
	event_bus.push_event("战斗_日志记录", [name, "加入连锁的动画", [life, card], true])
	
	return true


func 行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#悬置
	card.get_parent().remove_card(card)
	
	#动画
	await 可以继续
	#后续
	
	
	life.cards_pos["行动"].add_card(card)
	卡牌打出与发动系统.发动场上的效果(card, "打出")
	
	event_bus.push_event("战斗_日志记录", [name, "行动打出", [life, card], true])
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 非行动打出(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	
	
	#悬置
	card.get_parent().remove_card(card)
	
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	卡牌打出与发动系统.发动场上的效果(card, "打出")
	
	event_bus.push_event("战斗_日志记录", [name, "非行动打出", [life, card, pos], true])
	_add_history(life, "打出", card)
	_add_history(card, "打出")
	
	#buff判断
	await buff系统.单位与全部buff判断("打出", [null, life, card])
	
	return true


func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	卡牌打出与发动系统.发动场上的效果(card, "启动")
	
	event_bus.push_event("战斗_日志记录", [name, "构造", [life, card, pos], true])
	_add_history(life, "构造", card)
	_add_history(card, "构造")
	
	#buff判断
	await buff系统.单位与全部buff判断("构造", [null, life, card])
	
	return true


func 非场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	#检查
	var o_pos:String = card.get_parent().name
	
	
	#悬置
	card.get_parent().remove_card(card)
	
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	卡牌打出与发动系统.发动场上的效果(card, o_pos)
	
	event_bus.push_event("战斗_日志记录", [name, "非场上发动", [life, card, pos], true])
	_add_history(life, "发动", card)
	_add_history(card, "发动")
	
	#buff判断
	await buff系统.单位与全部buff判断("发动", [null, life, card])
	
	return true


func 场上发动(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await 可以继续
	#后续
	卡牌打出与发动系统.发动场上的效果(card, "直接")
	
	event_bus.push_event("战斗_日志记录", [name, "非场上发动", [life, card], true])
	
	
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
	await buff系统.单位与全部buff判断("改变方向", [null, life, card])
	
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
	await buff系统.单位与全部buff判断("反转", [null, life, card])
	
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
	await buff系统.单位与全部buff判断("加入", [null, life, card])
	
	return true


func 创造(life:战斗_单位管理系统.Life_sys, card_name:String) -> 战斗_单位管理系统.Card_sys:
	#判断
	
	#悬置
	var card:= 单位管理系统.create_card(card_name)
	#动画
	await 可以继续
	#后续
	
	event_bus.push_event("战斗_日志记录", [name, "创造", [life, card_name], card])
	_add_history(life, "创造", card)
	_add_history(card, "创造")
	
	#buff判断
	await buff系统.单位与全部buff判断("创造", [null, life, card])
	
	return card


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
	
	await buff系统.单位与全部buff判断("抽牌", [null, life, card])
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	释放与源.添加释放卡牌(life, card)
	
	event_bus.push_event("战斗_日志记录", [name, "释放", [life, card], true])
	_add_history(life, "释放", card)
	_add_history(card, "释放")
	
	#buff判断
	await buff系统.单位与全部buff判断("释放", [null, life, card])
	
	return true


func 直接攻击(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	#动画
	await 可以继续
	#后续
	
	event_bus.push_event("战斗_日志记录", [name, "直接攻击", [life, card], true])
	_add_history(life, "直接攻击", card)
	_add_history(card, "直接攻击")
	
	#buff判断
	await buff系统.单位与全部buff判断("攻击", [null, life, card])
	await buff系统.单位与全部buff判断("直接攻击", [null, life, card])
	
	return true






#无动画
func 直接释放(card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "直接释放", [card], null])
	
	释放与源.all_mp += 1
	if card.data.name != "源" and !释放与源.cards.has(card.data.name):
		释放与源.cards.append(card.data.name)
	
	card.free_self()
