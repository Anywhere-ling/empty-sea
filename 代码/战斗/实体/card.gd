extends Node2D
class_name Card

@onready var 种类: TextureRect = %种类
@onready var 卡名: Label = %卡名
@onready var 卡图: TextureRect = %卡图
@onready var 检测: Panel = %检测
@onready var 里侧: Panel = %里侧
@onready var 主要区域: PanelContainer = %主要区域


signal 图片或文字改变

var card_data:CardData


func _init(card_name:String = "") -> void:
	if card_name:
		card_data = DatatableLoader.get_data_model("card_data", card_name)
		display()
	
	

func display() -> void:
	if FileAccess.file_exists(文件路径.png卡牌种类(card_data.卡名)):
		卡图.texture = load(文件路径.png卡牌种类(card_data.卡名))
	else :
		卡图.texture = load(文件路径.png_test())
	种类.texture = load(文件路径.png卡牌种类(card_data.种类))
	卡名.text = card_data.卡名
	emit_signal("图片或文字改变")






func _on_左键_button_up() -> void:
	print(1)


func _on_右键_button_up() -> void:
	pass # Replace with function body.


func _on_检测_mouse_entered() -> void:
	print(2)
