extends PanelContainer

@onready var 文本: RichTextLabel = %文本

@onready var 确认: Button = %确认

signal 按钮按下


func set_card(text:String) -> void:
	文本.text = text
	visible = true




func _on_确认_button_up() -> void:
	visible = false
	emit_signal("按钮按下")
