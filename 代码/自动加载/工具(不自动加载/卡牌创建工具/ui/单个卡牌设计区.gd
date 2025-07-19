extends 卡牌创建工具_单个设计区
class_name 卡牌创建工具_单个卡牌设计区


@onready var sp: SpinBox = %sp
@onready var mp: SpinBox = %mp
@onready var 特征: 卡牌创建工具_不定数量的数据节点容器_h = %特征
@onready var 媒介: 卡牌创建工具_不定数量的数据节点容器_h = %媒介
@onready var 组: 卡牌创建工具_不定数量的数据节点容器_h = %组
@onready var 文本: TextEdit = %文本







func _ready() -> void:
	#连接信号
	效果设计区.请求检测空效果.connect(_请求检测空效果的信号)
	特征.子数据节点数量改变.connect(_请求检测空效果的信号)
	媒介.子数据节点数量改变.connect(_请求检测空效果的信号)
	组.子数据节点数量改变.connect(_请求检测空效果的信号)
	




	










func _请求检测空效果的信号(node:卡牌创建工具_效果设计区) -> void:
	_remove_empty_effects()
	emit_signal("请求储存到历史记录")
	




func _on_关闭_button_up() -> void:
	emit_signal("请求关闭该卡牌", self)


func _on_前进_button_up() -> void:
	history_index += 1
	emit_signal("请求读取历史记录", history[history_index])



func _on_后退_button_up() -> void:
	history_index -= 1
	emit_signal("请求读取历史记录", history[history_index])



func _on_卡名_text_changed(new_text: String) -> void:
	name = new_text
	emit_signal("请求储存到历史记录")


func _on_卡名_editing_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		emit_signal("请求储存到历史记录")

func _on_种类_item_selected(index: int) -> void:
	emit_signal("请求储存到历史记录")


func _on_sp_value_changed(value: float) -> void:
	emit_signal("请求储存到历史记录")


func _on_mp_value_changed(value: float) -> void:
	emit_signal("请求储存到历史记录")


func _on_文本_text_changed() -> void:
	emit_signal("请求储存到历史记录")
