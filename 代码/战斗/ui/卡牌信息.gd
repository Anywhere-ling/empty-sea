extends PanelContainer

@onready var 卡牌复制: 战斗_卡牌复制 = %卡牌复制
@onready var 文本: RichTextLabel = %文本
@onready var 组: HFlowContainer = %组
@onready var 特征: HFlowContainer = %特征
@onready var 活性源: Label = %活性源
@onready var 惰性源: Label = %惰性源

var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var card_gui:Card
var 组_arr:Array
var 特征_arr:Array
var 活性源_int:int
var 惰性源_int:int


func _ready() -> void:
	event_bus.subscribe("战斗_卡牌被左键点击", set_card)
	event_bus.subscribe("战斗_右键点击", remove_card)


func set_card(card:Card) -> void:
	if card_gui:
		card_gui.卡牌信息改变.disconnect(set_组和特征)
		card_gui.源数量改变.disconnect(set_源)
	卡牌复制.set_card(card)
	if card.card_sys.appear:
		card_gui = card
		set_文本(card)
		card._图片或文字改变的信号("组")
		card._图片或文字改变的信号("特征")
		card.卡牌信息改变.connect(set_组和特征)
		card.源数量改变.connect(set_源)
		set_组和特征(card)
		set_源()
	else :
		set_文本(null)
		set_组和特征(null)
		set_源()
	
	visible = true

func set_组和特征(card:Card) -> void:
	if !visible:
		return
	
	for i in 组.get_children():
		组.remove_child(i)
		i.queue_free()
	组_arr = []
	for i in 特征.get_children():
		特征.remove_child(i)
		i.queue_free()
	特征_arr = []
	
	if card:
		for i:String in card.组:
			var lab: = Label.new()
			lab.text = i
			组.add_child(lab)
			组_arr.append(i)
		
		for i:String in card.特征:
			var lab: = Label.new()
			lab.text = i
			特征.add_child(lab)
			特征_arr.append(i)

func set_源() -> void:
	if !visible:
		return
	活性源_int = 0
	惰性源_int = 0
	if card_gui:
		活性源_int = len(card_gui.card_sys.get_源(true))
		惰性源_int = len(card_gui.card_sys.get_源(false))
	
	活性源.text = str(活性源_int)
	惰性源.text = str(惰性源_int)

func set_文本(card:Card) -> void:
	if !card or card.card_sys.effects == []:
		文本.text = ""
		return
	
	var card_文本:String = card.card_sys.data["文本"]
	var indexs:Array = ["①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩"]
	var color:Dictionary={
		"发动次数小于一":Color.GRAY,
		"即将发动":Color.YELLOW,
		"可以发动":Color.SKY_BLUE,
	}
	var 文本s:PackedStringArray
	var 处理序号:int = 0
	var 可以继续:bool = true
	while 可以继续:
		处理序号 += 1
		var text1:String = card_文本.get_slice(indexs[处理序号], 0)
		if text1 == card_文本:
			可以继续 = false
		var text2:String = card_文本.get_slice(indexs[处理序号], 1)
		text2 = indexs[处理序号] + text2
		
		var eff:战斗_单位管理系统.Effect_sys = card.card_sys.effects[处理序号-1]
		if eff.颜色信息:
			text1 = "[color=" + color[eff.颜色信息].to_html() + "]" + text1
			text1 = text1 + "[/color]"
		文本s.append(text1)
		card_文本 = text2
	
	文本.text = "".join(文本s)





func remove_card() -> void:
	if card_gui:
		card_gui.卡牌信息改变.disconnect(set_组和特征)
		card_gui.源数量改变.disconnect(set_源)
		card_gui = null
	卡牌复制.free_card()
	文本.text = ""
	visible = false
