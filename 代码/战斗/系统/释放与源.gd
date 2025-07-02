extends Node


var 这个回合释放过的单位:Array[战斗_单位管理系统.Life_sys]
var 会释放的卡牌:Array[战斗_单位管理系统.Card_sys]
var all_mp:int = 0
var cards:Array[String]


func 添加释放卡牌(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> void:
	这个回合释放过的单位.append(life)
	会释放的卡牌.append(card)

func 释放卡牌() -> void:
	for card:战斗_单位管理系统.Card_sys in 会释放的卡牌:
		all_mp += 1
		if card.data.name != "源" and !cards.has(card.data.name):
			cards.append(card.data.name)
