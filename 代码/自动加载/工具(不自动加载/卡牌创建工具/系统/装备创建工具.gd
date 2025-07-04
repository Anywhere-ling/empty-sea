extends 创建工具
class_name 装备创建工具



@onready var 卡牌: 卡牌创建工具_带搜索的选择器 = %卡牌
@onready var buff: 卡牌创建工具_带搜索的选择器 = %buff
@onready var 媒介: 卡牌创建工具_带搜索的选择器 = %媒介





var specification_影响:Dictionary = {
	"发动判断":"对于卡牌是否能发动的限制",
}


#规范文件的加载数据





func _ready() -> void:
	await DatatableLoader.加载完成
	_加载卡牌数据()
	_加载规范文件并处理数据()
	_将数据写入选择器()
	卡牌.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	buff.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	媒介.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	
	add_单个角色设计区()






func _将数据写入选择器() -> void:
	buff.choose_data = buffs_data.keys()
	buff.start_build()
	卡牌.choose_data = cards_data.keys()
	卡牌.start_build()
	媒介.choose_data = specification_媒介
	媒介.start_build()
	文件.choose_data = equips_data.keys()
	文件.start_build()







func _add_node(node:BoxContainer, s:String) -> Control:
	if node.tooltip_text == "媒介":
		if specification_媒介.has(s):
			return _add_node_文本(node, s)
	elif node.tooltip_text == "卡牌":
		if cards_data.has(s):
			return _add_node_文本(node, s)
	elif node.tooltip_text == "buff":
		if buffs_data.has(s):
			return _add_node_文本(node, s)
	return 




func save_card(card_node:卡牌创建工具_单个设计区) -> Dictionary:
	var life_data:Dictionary
	life_data["卡名"] = _tran_node_to_data(card_node.卡名)
	life_data["媒介"] = _tran_node_to_data(card_node.媒介)
	life_data["重量"] = _tran_node_to_data(card_node.重量)
	life_data["卡牌"] = _tran_node_to_data(card_node.卡牌)
	life_data["buff"] = _tran_node_to_data(card_node.buff)
	
	
	
	
	
	return life_data





func add_单个角色设计区() -> 卡牌创建工具_单个装备设计区:
	var node:卡牌创建工具_单个装备设计区 = load(文件路径.tscn卡牌创建工具_装备_单个卡牌设计区()).instantiate()
	卡牌设计区容器.add_child(node)
	卡牌设计区容器.current_tab = 卡牌设计区容器.get_tab_idx_from_control(node)
	node.请求关闭该卡牌.connect(_请求删除卡牌设计区的信号)
	node.请求储存到历史记录.connect(_请求保存历史记录的信号)
	node.请求读取历史记录.connect(_请求读取历史记录的信号)
	node.name = "[空]"
	return node

func load_card(card_data:Dictionary) -> 卡牌创建工具_单个装备设计区:
	读取中 = true
	card_data = card_data.duplicate(true)
	var node:卡牌创建工具_单个装备设计区 = add_单个角色设计区()
	node.卡名.text = card_data["卡名"]
	node.name = card_data["卡名"]
	
	node.重量.value = card_data["重量"]
	

	for i:String in card_data["媒介"]:
		_add_node(node.媒介, i)
		
	for i:String in card_data["卡牌"]:
		_add_node(node.卡牌, i)
		
	for i:String in card_data["buff"]:
		_add_node(node.buff, i)
	
	
	读取中 = false
	return node






	
func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(equips_data[文件.choose_data[文件.choose_index]])


func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
	var file = FileAccess.open(文件路径.folder装备() + data["卡名"] + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "   ", true, true))  # 写入内容（可为空）
	file.close()
	
	save_不可为空 = false
	读取中 = false




func _on_新建_button_up() -> void:
	add_单个角色设计区()
