extends PanelContainer

@onready var 文本: Label = %文本
@onready var 确认: Button = %确认

signal 按钮按下


func set_card(test:String) -> void:
	文本.text = test
	visible = true




func _on_确认_button_up() -> void:
	visible = false
	emit_signal("按钮按下")
