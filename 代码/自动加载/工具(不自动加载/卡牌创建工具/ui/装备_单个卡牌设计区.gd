extends 卡牌创建工具_单个设计区
class_name 卡牌创建工具_单个装备设计区


@onready var 卡牌: 卡牌创建工具_不定数量的数据节点容器_h = %卡牌
@onready var 媒介: 卡牌创建工具_不定数量的数据节点容器_h = %媒介
@onready var 重量: SpinBox = %重量
@onready var buff: 卡牌创建工具_不定数量的数据节点容器_h = %buff









func _ready() -> void:
	#连接信号
	效果设计区.请求检测空效果.connect(_请求检测空效果的信号)
	卡牌.子数据节点数量改变.connect(_请求检测空效果的信号)
	媒介.子数据节点数量改变.connect(_请求检测空效果的信号)
	buff.子数据节点数量改变.connect(_请求检测空效果的信号)









func _on_重量_value_changed(value: float) -> void:
	emit_signal("请求储存到历史记录")
