extends Control

signal 可以继续
signal 动画完成

@onready var 最终行动系统: Node = %最终行动系统
@onready var gui_场上: 战斗_场上 = %gui_场上


var 对照表:Dictionary[String, Dictionary] = {
	"card":{},
	"life":{},
	"pos":{},
}
var dic动画:Dictionary[String, Dictionary] = {
	"加入":{"":{}
		
	}
}

func _ready() -> void:
	var 动画表 = preload(文件路径.res_动画表).new()
	dic动画 = 动画表.dic动画


func create_动画(tapy:String, data:Dictionary) -> 战斗_动画:
	var tapy动画:Dictionary = dic动画[tapy]
	var 符合动画
	for 动画:String in tapy动画:
		if tapy动画[动画].has("card") and tapy动画[动画]["card"] == data["card"].nam:
			var 全部符合:bool = true
			for i:String in tapy动画[动画]:
				if !tapy动画[动画][i] == data[i].nam:
					全部符合 = false
			if 全部符合:
				符合动画 = 动画
	if !符合动画:
		符合动画 = tapy
	
	data = data转换(data)
	符合动画 = load(文件路径.folder战斗动画 + 符合动画 +".gd").new(data)
	add_child(符合动画)
	return 符合动画


func data转换(data):
	if data is Dictionary:
		for i:String in data:
			if data[i] is 战斗_单位管理系统.Life_sys:
				data[i] = 对照表["life"][data[i]]
			elif data[i] is 战斗_单位管理系统.Card_sys:
				data[i] = 对照表["card"][data[i]]
			elif data[i] is 战斗_单位管理系统.Card_pos_sys:
				data[i] = 对照表["pos"][data[i]]
		return data
	elif data is 战斗_单位管理系统.Life_sys:
		return 对照表["life"][data]
	elif data is 战斗_单位管理系统.Card_sys:
		return 对照表["card"][data]
	elif data is 战斗_单位管理系统.Card_pos_sys:
		return 对照表["pos"][data]

func add_对照表(data) -> void:
	if data is 战斗_life:
		var life:战斗_life = data
		var life_sys:战斗_单位管理系统.Life_sys = life.life_sys
		对照表["life"][life_sys] = life
		对照表["pos"][life_sys.cards_pos["手牌"]] = life.手牌
		对照表["pos"][life_sys.cards_pos["白区"]] = life.卡牌五区.白区
		对照表["pos"][life_sys.cards_pos["绿区"]] = life.卡牌五区.绿区
		对照表["pos"][life_sys.cards_pos["蓝区"]] = life.卡牌五区.蓝区
		对照表["pos"][life_sys.cards_pos["红区"]] = life.卡牌五区.红区
		对照表["pos"][life_sys.cards_pos["行动"]] = life.行动
	
	elif data is Card:
		var card:Card = data
		var card_sys:战斗_单位管理系统.Card_sys = card.card_sys
		对照表["card"][card_sys] = card
	
	elif data is 战斗_场上_单格:
		var pos:战斗_场上_单格 = data
		var pos_sys:战斗_单位管理系统.Pos_cs_sys = pos.pos_sys
		对照表["pos"][pos_sys] = pos
	


func start_动画(动画:战斗_动画) -> void:
	动画.可以继续.connect(emit_可以继续, 5)
	动画.动画完成.connect(emit_动画完成, 5)
	动画.start()

func emit_可以继续(动画index:int) -> void:
	最终行动系统.call("emit_signal", "可以继续", 动画index)

func emit_动画完成() -> void:
	#await get_tree().create_timer(0.2).timeout
	最终行动系统.call("emit_signal", "动画完成")



func add_card(card:Card) -> void:
	if card.get_parent():
		card.get_parent().remove_child(card)
	
	add_child(card)
	card.set_pos(self)

func remove_card(card:Card) -> void:
	remove_child(card)
