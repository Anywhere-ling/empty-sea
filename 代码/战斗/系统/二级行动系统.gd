extends Node


@onready var 释放与源: Node = %释放与源
@onready var 最终行动系统: Node = %最终行动系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统
@onready var 单位控制系统: Node = %单位控制系统
@onready var 单位管理系统: 战斗_单位管理系统 = %单位管理系统

func _吃掉源检测(pos:战斗_单位管理系统.Card_pos_sys) -> void:
	if pos.nam in ["场上"]:
		var card:战斗_单位管理系统.Card_sys
		var dir:int
		if pos.cards:
			if pos.cards[0].appear in [2,4,5]:
				card = pos.cards[0]
				dir = card.direction
		if card:
			for i in pos.cards:
				if i.appear <= 1 and i.direction == dir:
					await 填入(i.get_所属life(), card, i)
			
		card = null
		if len(pos.cards) >= 2:
			if pos.cards[1].appear in [2,4,5]:
				card = pos.cards[1]
		if card and card.direction != dir:
			for i in pos.cards:
				if i.appear <= 1 and i.direction != dir:
					await 填入(i.get_所属life(), card, i)


func _不在场上时除去源(card:战斗_单位管理系统.Card_sys, pos_nam:String = "蓝区") -> void:
	if card.get_parent().nam == "场上":
		return
	for i:战斗_单位管理系统.Card_sys in card.get_源(true) + card.get_源(false):
		await 去除(i.get_所属life(), card, i, pos_nam)



func 去除(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 源:战斗_单位管理系统.Card_sys, pos_nam:String) -> bool:
	var pos:战斗_单位管理系统.Card_pos_sys
	if 源.get_own() and pos_nam != "场上":
		pos = 源.get_own().cards_pos[pos_nam]
	if pos:
		if !await 最终行动系统.去除(life, card, 源, pos):
			return false
	else :
		card.remove_源(源)
		if !await 释放与源.添加释放卡牌(life, 源):
			return false
	
	卡牌打出与发动系统.eraes_自动下降(源)
	return true


func 破坏(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	if !await 最终行动系统.破坏(life, card):
		return false
	
	_不在场上时除去源(card, "绿区")
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	for i in card.get_源(true) + card.get_源(false):
		if i.get_own():
			await 释放与源.添加释放卡牌(i.get_own(), i)
		else:
			await 释放与源.添加释放卡牌(life, i)
	await 释放与源.添加释放卡牌(life, card)
	
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 加入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	var o_pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
	
	if !await 最终行动系统.加入(life, card, pos):
		return false
	
	_吃掉源检测(pos)
	_吃掉源检测(o_pos)
	_不在场上时除去源(card, pos.nam)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	if card.get_value("种类") == "法术":
		var ind:int = 单位管理系统.get_数据改变唯一标识()
		card.add_value("种类", ["等", "仪式", ind])
		await 最终行动系统.图形化数据改变(card.get_所属life(), card, "种类")
	
	
	if !await 最终行动系统.构造(life, card, pos):
		return false
	
	_吃掉源检测(pos)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	for i in card.get_value("sp"):
		if len(life.cards_pos["白区"].cards) > 0:
			await 填入(life, card, life.cards_pos["白区"].cards[0])
	
	return true


func 插入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	if !await 最终行动系统.插入(life, card, pos):
		return false
	
	_吃掉源检测(pos)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 填入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 源:战斗_单位管理系统.Card_sys) -> bool:
	for i:战斗_单位管理系统.Card_sys in 源.get_源(true) + 源.get_源(false):
		if i.appear != 0:
			await 最终行动系统.反转(life, i)
		if !await 填入(life, card, i):
			await 去除(life, card, i, "蓝区")
	
	if !await 最终行动系统.填入(life, card, 源):
		return false
	
	卡牌打出与发动系统.eraes_自动下降(源)
	
	return true


func 流填入(life:战斗_单位管理系统.Life_sys, 源:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Pos_cs_sys) -> bool:
	if !await 最终行动系统.流填入(life, 源, pos):
		return false
	
	return true
