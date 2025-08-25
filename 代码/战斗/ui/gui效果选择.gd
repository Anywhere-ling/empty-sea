extends PanelContainer

@onready var 文本: Label = %文本
@onready var 按钮: ItemList = %按钮

signal 确认按下

var select:int

func set_card(text:String, arr:Array) -> void:
	文本.text = text
	arr = arr.duplicate(true)
	arr.sort()
	
	for i:int in (arr[-1]+1):
		按钮.add_item("效果"+str(i+1))
		if !arr.has(i):
			按钮.set_item_disabled(i, true)
	
	visible = true


func _on_确认_button_up() -> void:
	var arr:Array = 按钮.get_selected_items()
	if arr:
		select = arr[0]
		按钮.clear()
		visible = false
		emit_signal("确认按下")
		
