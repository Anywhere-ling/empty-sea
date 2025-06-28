extends 创建工具
class_name buff创建工具



@onready var 影响: 卡牌创建工具_带搜索的选择器 = %影响
@onready var 组件: 卡牌创建工具_带搜索的选择器 = %组件
@onready var 特征: 卡牌创建工具_带搜索的选择器 = %特征
@onready var 标点: 卡牌创建工具_带搜索的选择器 = %标点




var specification_影响:Dictionary = {
	"发动判断":"对于卡牌是否能发动的限制",
}


#规范文件的加载数据





func _ready() -> void:
	await DatatableLoader.加载完成
	_加载卡牌数据()
	_加载规范文件并处理数据()
	_将数据写入选择器()
	影响.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组件.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特征.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	标点.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	
	add_单个角色设计区()






func _将数据写入选择器() -> void:
	标点.choose_data = specification_效果标点.keys()
	标点.start_build()
	特征.choose_data = specification_效果特征.keys()
	特征.start_build()
	组件.choose_data = specification_效果组件.keys()
	组件.start_build()
	影响.choose_data = specification_影响.keys()
	影响.start_build()
	文件.choose_data = buffs_data.keys()
	文件.start_build()







func _add_node(node:BoxContainer, s:String) -> Control:
	if specification_效果标点.has(s):
		if specification_效果标点[s][1] == "括号":
			return _add_node_括号(node, s)
	elif node.tooltip_text == "影响":
		if specification_影响.has(s):
			return _add_node_文本(node, s)
	elif node.tooltip_text == "组":
		if specification_组.has(s):
			return _add_node_文本(node, s)
	elif specification_效果特征.has(s):
		return _add_node_文本(node, s)
	elif specification_效果组件.has(s):
		return _add_node_组件(node, s)
	return 




func save_card(card_node:卡牌创建工具_单个设计区) -> Dictionary:
	var life_data:Dictionary
	life_data["卡名"] = _tran_node_to_data(card_node.卡名)
	life_data["影响"] = _tran_node_to_data(card_node.影响)
	life_data["优先"] = _tran_node_to_data(card_node.优先)
	#效果
	var arr:Array = []
	for i:卡牌创建工具_效果设计区 in card_node.效果.get_children():
		var i1:卡牌创建工具_不定数量的数据节点容器 = i.get_child(1)
		if len(i1.get_children()) > 2:
			arr.append(_翻译效果data(i1))
	life_data["效果"] = arr
	
	
	
	
	return life_data





func add_单个角色设计区() -> 卡牌创建工具_单个buff设计区:
	var node:卡牌创建工具_单个buff设计区 = load(文件路径.tscn卡牌创建工具_buff_单个卡牌设计区()).instantiate()
	卡牌设计区容器.add_child(node)
	卡牌设计区容器.current_tab = 卡牌设计区容器.get_tab_idx_from_control(node)
	node.请求关闭该卡牌.connect(_请求删除卡牌设计区的信号)
	node.请求储存到历史记录.connect(_请求保存历史记录的信号)
	node.请求读取历史记录.connect(_请求读取历史记录的信号)
	node.name = "[空]"
	return node

func load_card(card_data:Dictionary) -> 卡牌创建工具_单个buff设计区:
	读取中 = true
	card_data = card_data.duplicate(true)
	var node:卡牌创建工具_单个buff设计区 = add_单个角色设计区()
	node.卡名.text = card_data["卡名"]
	node.name = card_data["卡名"]
	
	node.优先.value = card_data["优先"]
	

	for i:String in card_data["影响"]:
		_add_node(node.影响, i)
	
	for i:Array in card_data["效果"]:
		var node1:卡牌创建工具_效果设计区 = node.效果.get_child(-1)
		for i1 in i:
			_翻译效果node(i1, node1.get_child(-1), node1.名字.get_child(-1))
	读取中 = false
	return node





func _选择器的请求显示简介的信号(choose:String) -> void:
	if specification_效果标点.has(choose):
		简介.text = specification_效果标点[choose][0]
	elif specification_影响.has(choose):
		简介.text = specification_影响[choose]
	elif specification_特征.has(choose):
		简介.text = specification_特征[choose]
	elif specification_效果特征.has(choose):
		简介.text = specification_效果特征[choose]
	elif specification_效果组件.has(choose):
		简介.text = specification_效果组件[choose][1]
	


func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(buffs_data[文件.choose_data[文件.choose_index]])


func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
	var file = FileAccess.open(文件路径.folderbuff() + data["卡名"] + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "   ", true, true))  # 写入内容（可为空）
	file.close()
	
	save_不可为空 = false
	读取中 = false




func _on_新建_button_up() -> void:
	add_单个角色设计区()
