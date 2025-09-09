extends PanelContainer

@onready var 文本: RichTextLabel = %文本
@onready var 按钮: ItemList = %按钮

signal 确认按下

var select:int

func set_card(card:Card, arr:Array) -> void:
	set_文本(card)
	arr = arr.duplicate(true)
	arr.sort()
	
	for i:int in (arr[-1]+1):
		按钮.add_item("效果"+str(i+1))
		if !arr.has(i):
			按钮.set_item_disabled(i, true)
	
	visible = true

func set_文本(card:Card) -> void:
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


func _on_确认_button_up() -> void:
	var arr:Array = 按钮.get_selected_items()
	if arr:
		select = arr[0]
		按钮.clear()
		visible = false
		emit_signal("确认按下")
		
