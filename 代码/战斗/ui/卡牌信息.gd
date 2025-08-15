extends PanelContainer

@onready var 卡牌复制: 战斗_卡牌复制 = %卡牌复制
@onready var 文本: Label = %文本
@onready var 组: HFlowContainer = %组
@onready var 特征: HFlowContainer = %特征

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var card_gui:Card
var 组_arr:Array
var 特征_arr:Array


func _ready() -> void:
	event_bus.subscribe("战斗_卡牌被左键点击", set_card)
	event_bus.subscribe("战斗_右键点击", remove_card)


func set_card(card:Card) -> void:
	if card_gui:
		card_gui.卡牌信息改变.disconnect(set_组和特征)
	卡牌复制.set_card(card)
	if card.card_sys.appear:
		文本.text = card.card_sys.data["文本"]
	card.卡牌信息改变.connect(set_组和特征)
	card_gui = card
	
	visible = true

func set_组和特征(card:Card) -> void:
	if 组_arr != card.组:
		for i in 组.get_children():
			组.remove_child(i)
			i.queue_free()
		for i:String in card.组:
			var lab: = Label.new()
			lab.text = i
			组.add_child(lab)
	
	if 特征_arr != card.特征:
		for i in 特征.get_children():
			特征.remove_child(i)
			i.queue_free()
		for i:String in card.特征:
			var lab: = Label.new()
			lab.text = i
			特征.add_child(lab)
	


func remove_card() -> void:
	if card_gui:
		card_gui.卡牌信息改变.disconnect(set_组和特征)
		card_gui = null
	卡牌复制.free_card()
	文本.text = ""
	visible = false
