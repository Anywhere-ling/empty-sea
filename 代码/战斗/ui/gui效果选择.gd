extends PanelContainer

@onready var 文本: Label = %文本
@onready var 按钮: ItemList = %按钮

signal 确认按下

var select:int

func set_card(text:String, arr:Array) -> void:
	文本.text = text
	for i:int in arr:
		按钮.add_item("效果"+str(i))
	visible = true


func _on_确认_button_up() -> void:
	if 按钮.get_selected_items():
		emit_signal("确认按下")
		select = 按钮.get_selected_items()[0]
		按钮.clear()
		visible = false
