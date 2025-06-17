extends HBoxContainer
class_name 卡牌创建工具_效果设计区


signal 请求检测空效果


@onready var 不定数量的数据节点容器: 卡牌创建工具_不定数量的数据节点容器 = $不定数量的数据节点容器
@onready var 名字: Label = %名字


func _ready() -> void:
	#连接信号
	不定数量的数据节点容器.子数据节点数量改变.connect(_子数据节点数量改变的信号)

##判断是否为空效果
func is_empty_effect() -> bool:
	return !不定数量的数据节点容器.has_child_node()







func _子数据节点数量改变的信号(node:卡牌创建工具_不定数量的数据节点容器) -> void:
	emit_signal("请求检测空效果" , self)
