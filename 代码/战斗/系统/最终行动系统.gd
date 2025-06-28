extends Node


@onready var buff系统: Node = $"../单位管理系统/buff系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

signal 可以继续


func 加入(card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> void:
	#悬置
	card.get_parent().remove_card(card)
	#动画
	await 可以继续
	#后续
	pos.add_card(card)
	
	event_bus.push_event("战斗_日志记录", [name, "加入", [card, pos], 0])
	#buff判断
	buff系统.单位与全部buff判断("加入", [null, null, card])
	

func 抽牌(life:战斗_单位管理系统.Life_sys) -> void:
	#悬置
	var card:战斗_单位管理系统.Card_sys = life.cards_pos["白区"].cards[0]
	card.get_parent().remove_card(card)
	
	#动画
	
	await 可以继续
	
	#后续
	life.cards_pos["手牌"].add_card(card)
	
	event_bus.push_event("战斗_日志记录", [name, "加入", [life], 0])
	
	buff系统.单位与全部buff判断("抽牌", [null, null, card])
