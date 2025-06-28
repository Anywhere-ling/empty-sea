extends 创建工具
class_name 单位创建工具




@onready var 卡牌: 卡牌创建工具_带搜索的选择器 = %卡牌
@onready var 数量: 卡牌创建工具_带搜索的选择器 = %数量
@onready var 组: 卡牌创建工具_带搜索的选择器 = %组





#规范文件的加载数据





func _ready() -> void:
	await DatatableLoader.加载完成
	_加载卡牌数据()
	_加载规范文件并处理数据()
	_将数据写入选择器()
	卡牌.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	数量.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	
	add_单个角色设计区()





func _将数据写入选择器() -> void:
	组.choose_data = specification_组
	组.start_build()
	卡牌.choose_data = cards_data.keys()
	卡牌.start_build()
	数量.choose_data = ["数量"]
	数量.start_build()
	文件.choose_data = lifes_data.keys()
	文件.start_build()







func _add_node(node:BoxContainer, s:String) -> Control:
	if ["数量"].has(s):
		return _add_node_任意输入(node, s)
	elif node.tooltip_text == "组":
		if specification_组.has(s):
			return _add_node_文本(node, s)
	elif cards_data.keys().has(s):
		return _add_node_文本(node, s)
	return 




func save_card(card_node:卡牌创建工具_单个设计区) -> Dictionary:
	var life_data:Dictionary
	life_data["卡名"] = _tran_node_to_data(card_node.卡名)
	life_data["种类"] = _tran_node_to_data(card_node.种类)
	life_data["大小"] = _tran_node_to_data(card_node.大小)
	life_data["组"] = _tran_node_to_data(card_node.组)
	#效果
	var arr:Array = []
	for i:卡牌创建工具_效果设计区 in card_node.效果.get_children():
		var i1:卡牌创建工具_不定数量的数据节点容器 = i.get_child(1)
		if len(i1.get_children()) > 2:
			arr.append(_翻译效果data(i1))
	life_data["效果"] = arr
	
	
	
	
	return life_data





func add_单个角色设计区() -> 卡牌创建工具_单个单位设计区:
	var node:卡牌创建工具_单个单位设计区 = load(文件路径.tscn卡牌创建工具_单位_单个卡牌设计区()).instantiate()
	卡牌设计区容器.add_child(node)
	卡牌设计区容器.current_tab = 卡牌设计区容器.get_tab_idx_from_control(node)
	node.请求关闭该卡牌.connect(_请求删除卡牌设计区的信号)
	node.请求储存到历史记录.connect(_请求保存历史记录的信号)
	node.请求读取历史记录.connect(_请求读取历史记录的信号)
	node.name = "[空]"
	return node

func load_card(card_data:Dictionary) -> 卡牌创建工具_单个单位设计区:
	读取中 = true
	card_data = card_data.duplicate(true)
	var node:卡牌创建工具_单个单位设计区 = add_单个角色设计区()
	node.卡名.text = card_data["卡名"]
	node.name = card_data["卡名"]
	if "种类":
		var index:int = -1
		for i:int in node.种类.item_count:
			if node.种类.get_item_text(i) == card_data["种类"]:
				index = i
		node.种类.select(index)
	node.大小.value = card_data["大小"]
	

	for i:String in card_data["组"]:
		_add_node(node.组, i)
	
	for i:Array in card_data["效果"]:
		var node1:卡牌创建工具_效果设计区 = node.效果.get_child(-1)
		for i1 in i:
			_翻译效果node(i1, node1.get_child(-1), node1.名字.get_child(-1))
	读取中 = false
	return node

func _翻译效果node(data, node:卡牌创建工具_不定数量的数据节点容器, focus:Control) -> void:
	if !data:
		return
	focus.grab_focus()
	if data.is_valid_int():
		_write_data_to_node(int(data), _add_node_数字输入(node))
	else :
		_add_node_文本(node, data)
	





		
		
		


func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(lifes_data[文件.choose_data[文件.choose_index]])


func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
	var file = FileAccess.open(文件路径.folder单位() + data["卡名"] + ".json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "   ", true, true))  # 写入内容（可为空）
	file.close()
	
	save_不可为空 = false
	读取中 = false




func _on_新建_button_up() -> void:
	add_单个角色设计区()
