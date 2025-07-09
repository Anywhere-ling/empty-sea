extends Node

@onready var 最终行动系统: Node = $"../最终行动系统"

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var 这个回合释放过的单位:Array[战斗_单位管理系统.Life_sys]
var 会释放的卡牌:Array[战斗_单位管理系统.Card_sys]
var all_mp:int = 0
var cards:Array[String]


func 添加释放卡牌(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "添加释放卡牌", [life, card], null])
	
	这个回合释放过的单位.append(life)
	会释放的卡牌.append(card)

func 释放卡牌() -> void:
	event_bus.push_event("战斗_日志记录", [name, "释放卡牌", [], null])
	
	for card:战斗_单位管理系统.Card_sys in 会释放的卡牌:
		最终行动系统.直接释放(card)
	
	会释放的卡牌 = []

func 添加源(life:战斗_单位管理系统.Life_sys) -> void:
	event_bus.push_event("战斗_日志记录", [name, "添加源", [life], null])
	
	if !这个回合释放过的单位.has(life):
		return
	这个回合释放过的单位.erase(life)
	for i:int in all_mp/2:
		var card:战斗_单位管理系统.Card_sys = 最终行动系统.创造(life, "源")
		life.cards_pos["蓝区"].add_card(card)
