extends Node


@onready var 释放与源: Node = %释放与源
@onready var 最终行动系统: Node = %最终行动系统
@onready var 卡牌打出与发动系统: Node = %卡牌打出与发动系统

func _吃掉素材检测(pos:战斗_单位管理系统.Card_pos_sys) -> void:
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
			

func _不在场上时除去素材(card:战斗_单位管理系统.Card_sys, pos_nam:String = "白区") -> void:
	if card.get_parent().nam == "场上":
		return
	for i:战斗_单位管理系统.Card_sys in card.get_素材(true) + card.get_素材(false):
		var pos:战斗_单位管理系统.Card_pos_sys
		if i.own:
			pos = i.own.cards_pos[pos_nam]
		await 去除(i.get_所属life(), card, i, pos)


func 去除(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 素材:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	if pos:
		return await 最终行动系统.去除(life, card, 素材, pos)
	else :
		card.remove_素材(素材)
		return await 释放与源.添加释放卡牌(life, 素材)


func 破坏(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	if !await 最终行动系统.破坏(life, card):
		return false
	
	_不在场上时除去素材(card, "绿区")
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 释放(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys) -> bool:
	for i in card.get_素材(true) + card.get_素材(false):
		if i.own:
			await 释放与源.添加释放卡牌(i.own, i)
		else:
			await 释放与源.添加释放卡牌(life, i)
	await 释放与源.添加释放卡牌(life, card)
	
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 加入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	var o_pos:战斗_单位管理系统.Card_pos_sys = card.get_parent()
	
	if !await 最终行动系统.加入(life, card, pos):
		return false
	
	_吃掉素材检测(pos)
	_吃掉素材检测(o_pos)
	_不在场上时除去素材(card)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 构造(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	if !await 最终行动系统.构造(life, card, pos):
		return false
	
	_吃掉素材检测(pos)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	for i in card.get_value("mp"):
		if len(life.cards_pos["白区"].cards) > 0:
			await 填入(life, card, life.cards_pos["白区"].cards[0])
	
	return true


func 插入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, pos:战斗_单位管理系统.Card_pos_sys) -> bool:
	if !await 最终行动系统.插入(life, card, pos):
		return false
	
	_吃掉素材检测(pos)
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true


func 填入(life:战斗_单位管理系统.Life_sys, card:战斗_单位管理系统.Card_sys, 素材:战斗_单位管理系统.Card_sys) -> bool:
	if !await 最终行动系统.填入(life, card, 素材):
		return false
	
	卡牌打出与发动系统.eraes_自动下降(card)
	
	return true
