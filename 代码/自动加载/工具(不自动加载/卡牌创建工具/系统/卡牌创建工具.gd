extends 创建工具
class_name 卡牌创建工具




@onready var 组件: 卡牌创建工具_带搜索的选择器 = %组件
@onready var 特征: 卡牌创建工具_带搜索的选择器 = %特征
@onready var 标点: 卡牌创建工具_带搜索的选择器 = %标点
@onready var 特: 卡牌创建工具_带搜索的选择器 = %特
@onready var 组: 卡牌创建工具_带搜索的选择器 = %组
@onready var buff: 卡牌创建工具_带搜索的选择器 = %buff
@onready var 影响: 卡牌创建工具_带搜索的选择器 = %影响

'''

①②③④⑤⑥⑦⑧⑨⑩•

逐一检测：
[["逐一", "对象3", ["以数据为对象", "对象3", "显现", "对象4"], 
["数据判断", "对象4", "相等", "0"], ["对象处理", "对象5", "加", "对象3"]]]

'''


func _ready() -> void:
	await DatatableLoader.加载完成
	_基本设置()
	
	_加载卡牌数据()
	_加载规范文件并处理数据()
	_将数据写入选择器()
	组件.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特征.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	标点.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	buff.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	文件.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	影响.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组件.请求显示简介.connect(_选择器的请求显示简介的信号)
	特征.请求显示简介.connect(_选择器的请求显示简介的信号)
	标点.请求显示简介.connect(_选择器的请求显示简介的信号)
	特.请求显示简介.connect(_选择器的请求显示简介的信号)
	影响.请求显示简介.connect(_选择器的请求显示简介的信号)
	
	add_单个卡牌设计区()




func _将数据写入选择器() -> void:
	标点.choose_data = specification_效果标点.keys()
	标点.start_build()
	特征.choose_data = specification_效果特征.keys()
	特征.start_build()
	组件.choose_data = specification_效果组件.keys()
	组件.start_build()
	特.choose_data = specification_特征.keys()
	特.start_build()
	组.choose_data = specification_组
	组.start_build()
	文件.choose_data = cards_data.keys()
	文件.start_build()
	buff.choose_data = buffs_data.keys()
	buff.start_build()
	影响.choose_data = specification_影响.keys()
	影响.start_build()







func _add_node(node:Control, s:String) -> Control:
	var nam:String = 选择器.get_current_tab_control().name
	if nam == "标点":
		if specification_效果标点.has(s):
			if specification_效果标点[s][1] == "括号":
				return _add_node_括号(node, s)
			if specification_效果标点[s][1] == "括号输入":
				return _add_node_括号(node, s, "等待输入")
	
	elif nam == "特":
		if node.tooltip_text == "特":
			if specification_特征.has(s):
				return _add_node_文本(node, s)
	
	elif nam == "组":
		if node.tooltip_text == "组":
			if specification_组.has(s):
				return _add_node_文本(node, s)
	
	elif nam == "特征":
		if specification_效果特征.has(s):
			return _add_node_文本(node, s)
	
	elif nam == "组件":
		if specification_效果组件.has(s):
			return _add_node_组件(node, s)
	
	elif nam == "buff":
		if buffs_data.has(s):
			var focus:Control = get_viewport().gui_get_focus_owner()
			if focus is LineEdit:
				focus.text = s
				return
			focus.grab_focus()
			return _add_node_文本(node, s)
	
	elif nam == "影响":
		if specification_影响.has(s):
			return _add_node_文本(node, s)
	
	elif nam == "文件":
		if cards_data.has(s):
			var focus:Control = get_viewport().gui_get_focus_owner()
			if focus is LineEdit:
				focus.text = s
			return
	return



func save_card(card_node:卡牌创建工具_单个设计区) -> Dictionary:
	var card_data:Dictionary
	card_data["卡名"] = _tran_node_to_data(card_node.卡名)
	card_data["种类"] = _tran_node_to_data(card_node.种类)
	card_data["sp"] = _tran_node_to_data(card_node.sp)
	card_data["mp"] = _tran_node_to_data(card_node.mp)
	card_data["特征"] = _tran_node_to_data(card_node.特征)
	card_data["媒介"] = _tran_node_to_data(card_node.媒介)
	card_data["组"] = _tran_node_to_data(card_node.组)
	card_data["文本"] = _tran_node_to_data(card_node.文本)
	#效果
	var arr:Array = []
	for i:Control in card_node.效果.get_children():
		if i is 卡牌创建工具_效果设计区:
			var i1:卡牌创建工具_不定数量的数据节点容器 = i.get_child(1)
			if len(i1.get_children()) > 2:
				arr.append(_翻译效果data(i1))
	card_data["效果"] = arr
	
	
	
	
	return card_data



func add_单个卡牌设计区() -> 卡牌创建工具_单个卡牌设计区:
	var node:卡牌创建工具_单个卡牌设计区 = preload(文件路径.tscn卡牌创建工具_单个卡牌设计区).instantiate()
	卡牌设计区容器.add_child(node)
	卡牌设计区容器.current_tab = 卡牌设计区容器.get_tab_idx_from_control(node)
	node.请求关闭该卡牌.connect(_请求删除卡牌设计区的信号)
	node.请求储存到历史记录.connect(_请求保存历史记录的信号)
	node.请求读取历史记录.connect(_请求读取历史记录的信号)
	node.name = "[空]"
	return node

func load_card(card_data:Dictionary) -> 卡牌创建工具_单个卡牌设计区:
	读取中 = true
	card_data = card_data.duplicate(true)
	var node:卡牌创建工具_单个卡牌设计区 = add_单个卡牌设计区()
	node.卡名.text = card_data["卡名"]
	node.name = card_data["卡名"]
	if "种类":
		var index:int = -1
		for i:int in node.种类.item_count:
			if node.种类.get_item_text(i) == card_data["种类"]:
				index = i
		node.种类.select(index)
	node.sp.value = int(card_data["sp"])
	node.mp.value = int(card_data["mp"])
	node.文本.text = card_data["文本"]
	
	for i:String in card_data["特征"]:
		改变选择器("特征")
		_add_node(node.特征, i)
	for i:String in card_data["组"]:
		改变选择器("组")
		_add_node(node.组, i)
	
	for i:Array in card_data["效果"]:
		var node1:卡牌创建工具_效果设计区
		var arr:Array = node.效果.get_children()
		arr.reverse()
		for i1:Control in arr:
			if i1 is 卡牌创建工具_效果设计区:
				node1 = i1
				break
		for i1 in i:
			_翻译效果node(i1, node1.get_child(-1), node1.名字.get_child(-1))
	读取中 = false
	改变选择器("文件")
	return node






func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(cards_data[文件.choose_data[文件.choose_index]])
	
	_请求保存历史记录的信号()


func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
	if  data["卡名"]:
		var file = FileAccess.open(文件路径.folder卡牌 + data["卡名"] + ".json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data, "   ", true, true))  # 写入内容（可为空）
		file.close()
	
	save_不可为空 = false
	读取中 = false


func _on_复制_button_up() -> void:
	var nodes:Array = _get_焦点按钮s()
	copy_node(nodes)


func _on_粘贴_button_up() -> void:
	stackup_node()


func _on_新建_button_up() -> void:
	add_单个卡牌设计区()


func _on_确认_button_up() -> void:
	push_error.visible = false
