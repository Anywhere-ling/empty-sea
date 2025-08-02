extends 创建工具
class_name 卡牌创建工具




@onready var 组件: 卡牌创建工具_带搜索的选择器 = %组件
@onready var 特征: 卡牌创建工具_带搜索的选择器 = %特征
@onready var 标点: 卡牌创建工具_带搜索的选择器 = %标点
@onready var 特: 卡牌创建工具_带搜索的选择器 = %特
@onready var 媒: 卡牌创建工具_带搜索的选择器 = %媒
@onready var 组: 卡牌创建工具_带搜索的选择器 = %组
@onready var buff: 卡牌创建工具_带搜索的选择器 = %buff




#规范文件的加载数据





func _ready() -> void:
	await DatatableLoader.加载完成
	_加载卡牌数据()
	_加载规范文件并处理数据()
	_将数据写入选择器()
	组件.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特征.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	标点.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	媒.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	buff.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组件.请求显示简介.connect(_选择器的请求显示简介的信号)
	特征.请求显示简介.connect(_选择器的请求显示简介的信号)
	标点.请求显示简介.connect(_选择器的请求显示简介的信号)
	特.请求显示简介.connect(_选择器的请求显示简介的信号)
	
	
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
	媒.choose_data = specification_媒介
	媒.start_build()
	组.choose_data = specification_组
	组.start_build()
	文件.choose_data = cards_data.keys()
	文件.start_build()
	buff.choose_data = buffs_data.keys()
	buff.start_build()







func _add_node(node:BoxContainer, s:String) -> Control:
	if specification_效果标点.has(s):
		if specification_效果标点[s][1] == "括号":
			return _add_node_括号(node, s)
		if specification_效果标点[s][1] == "括号输入":
			return _add_node_括号(node, s, "等待输入")
	elif node.tooltip_text == "特征":
		if specification_特征.has(s):
			return _add_node_文本(node, s)
	elif node.tooltip_text == "媒介":
		if specification_媒介.has(s):
			return _add_node_文本(node, s)
	elif node.tooltip_text == "组":
		if specification_组.has(s):
			return _add_node_文本(node, s)
	elif specification_效果特征.has(s):
		return _add_node_文本(node, s)
	elif specification_效果组件.has(s):
		return _add_node_组件(node, s)
	elif buffs_data.has(s):
		return _add_node_文本(node, s)
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



#将节点翻译成数据
func _tran_node_to_data(node:Control) -> Variant:
	var ret
	if node is Label :
		ret = node.text
	elif node is LineEdit :
		ret = node.text
	elif node is TextEdit :
		ret = node.text
	elif node is SpinBox :
		ret = str(node.value)
	elif node is OptionButton :
		if node.selected == -1:
			ret = ""
		else:
			ret = node.get_item_text(node.selected)
	elif node is 卡牌创建工具_不定数量的数据节点容器 or node is 卡牌创建工具_不定数量的数据节点容器_h :
		var arr:Array = []
		for index:int in len(node.get_children()) - 2:
			arr.append(_tran_node_to_data(node.get_children()[index]))
		ret = arr
	elif node is BoxContainer:
		var arr:Array = []
		for index:int in len(node.get_children()):
			arr.append(_tran_node_to_data(node.get_children()[index]))
		ret = arr
	else :
		assert(false , "不能处理的类型")
		return []
	
	if save_不可为空 and !ret:
		
		if node is 卡牌创建工具_不定数量的数据节点容器_h:
			if node.tooltip_text == "多选":
				return ret
			node.get_parent().get_child(0).grab_focus()
		else :
			node.grab_focus()
		_push_error("有数据为空")
	
	return ret



func add_单个卡牌设计区() -> 卡牌创建工具_单个卡牌设计区:
	var node:卡牌创建工具_单个卡牌设计区 = load(文件路径.tscn卡牌创建工具_单个卡牌设计区()).instantiate()
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
		_add_node(node.特征, i)
	for i:String in card_data["媒介"]:
		_add_node(node.媒介, i)
	for i:String in card_data["组"]:
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
	return node




#写入数据到单个节点
func _write_data_to_node(data, node:Control) -> void:
	if node is LineEdit:
		assert(data is String, "数据类型错误")
		node.text = data
	elif node is SpinBox:
		assert(data is int or data is String, "数据类型错误")
		node.value = int(data)
	elif node is OptionButton:
		assert(data is String, "数据类型错误")
		for i:int in node.item_count:
			if data == node.get_item_text(i):
				node.select(i)
				break
		assert(node.selected != -1, "没有这个选项")
	elif node is 卡牌创建工具_不定数量的数据节点容器_h:
		assert(data is Array, "数据类型错误")
		for s:String in data:
			for i:int in node.选项卡.item_count:
				if s == node.选项卡.get_item_text(i):
					node.选项卡.select(i)
					break
			assert(node.选项卡.selected != -1, "没有这个选项")
			node.加.grab_focus()
			node.加.emit_signal("button_up")
	else :
		assert(false, "无法识别")





#复制数据节点
func copy_node(focus:Control) -> void:
	var path:String = 卡牌设计区容器.get_current_tab_control().卡名.text + "/"
	var node:Node
	#焦点在最左边的label
	if focus.get_parent().tooltip_text == "基础数据节点容器的名字":
		path += focus.get_parent().text
		node = focus.get_parent().get_parent().get_child(1)
		路径.text = path
		_存入储存区(node)
		return
	
	node = _find_parent(focus)
	if node:
		var node_pa:Node = node.get_parent()
		if node_pa.get_parent() is 卡牌创建工具_效果设计区:
			path += node_pa.get_parent().名字.text + "/"
		else :
			path += node_pa.get_parent().get_child(0).text + "/"
		if node is Label:
			path += node.text
		elif node is HBoxContainer:
			path += str(node.get_index()) + "/"
			path += node.get_child(0).text
		else:
			assert(true, "不能处理的类型")
		路径.text = path
		_存入储存区(node)


func _存入储存区(node:Control) -> void:
	#转成文字
	var data:Array
	if node is 卡牌创建工具_不定数量的数据节点容器 or node is 卡牌创建工具_不定数量的数据节点容器_h:
		var path_end:String = (路径.text).split("/")[1]
		assert(path_end in ["卡名 ", "种类 ", "sp    ", "mp   ", "特征 ", "媒介 ", "组     ", "文本 ", "效果"], "路径不匹配")
		if path_end != "效果":
			data = _tran_node_to_data(node)
		else:
			data = _翻译效果data(node)
	else :
		data = _tran_node_to_data(node)
	copy_node_data = data
		

#粘贴
func stackup_node() -> void:
	var node:卡牌创建工具_单个卡牌设计区 = 卡牌设计区容器.get_current_tab_control()
	if !copy_node_data :
		return
	#
	var path_arr:Array = 路径.text.split("/")
	assert(path_arr[1] in ["卡名 ", "种类 ", "sp    ", "mp   ", "特征 ", "媒介 ", "组     ", "文本 ", "效果"], "路径不匹配")
	if len(path_arr) < 3 or path_arr[1] == "效果" and len(path_arr) < 4:
		if path_arr[1] == "特征 ":
			for i:String in copy_node_data:
				_add_node(node.特征, i)
		elif path_arr[1] == "媒介 ":
			for i:String in copy_node_data:
				_add_node(node.媒介, i)
		elif path_arr[1] == "组     ":
			for i:String in copy_node_data:
				_add_node(node.组, i)
		
		elif path_arr[1] == "效果":
			var node1:卡牌创建工具_效果设计区 = node.效果.get_child(-2)
			for i1 in copy_node_data:
				_翻译效果node(i1, node1.get_child(-1), node1.名字.get_child(-1))
		else:
			assert(true, "不合规范的数据")
	else:
		assert(path_arr[1] == "效果", "不合规范的数据")
		var node1:Control = _将选项翻译并添加到指定的地方(copy_node_data[0])
		var arr:Array = node1.get_children()
		for i:int in len(arr):
			if i == 0:
				continue
			_write_data_to_node(copy_node_data[i], arr[i])
	

func _将选项翻译并添加到指定的地方(choose:String) -> Control:
	var focus:Control = get_viewport().gui_get_focus_owner()
	#焦点在最左边的label
	if focus and focus.get_parent().tooltip_text == "基础数据节点容器的名字":
		return _add_node(focus.get_parent().get_parent().get_child(1), choose)
		
	var node:Node = _find_parent(focus)
	if node:
		return _add_node(node.get_parent(), choose)
	return


##向上寻找，直到父节点为基础数据节点容器
func _find_parent(node:Control) -> Control:
	if node:
		while !(node.get_parent() is 卡牌创建工具_不定数量的数据节点容器 or node.get_parent() is 卡牌创建工具_不定数量的数据节点容器_h):
			if !node or !node.get_parent() is Control:
				return null
			node = node.get_parent()
		if node.get_parent().选项卡.visible == true:
			return node.get_parent().get_parent()
		else:
			return node
	return null



func _push_error(text:String) -> void:
	push_error.get_child(0).get_child(0).text = text
	push_error.visible = true


func _选择器的确认按钮被按下的信号(choose:String) -> void:
	_将选项翻译并添加到指定的地方(choose)





func _选择器的请求显示简介的信号(choose:String) -> void:
	if specification_效果标点.has(choose):
		简介.text = specification_效果标点[choose][0]
	elif specification_特征.has(choose):
		简介.text = specification_特征[choose]
	elif specification_效果特征.has(choose):
		简介.text = specification_效果特征[choose]
	elif specification_效果组件.has(choose):
		简介.text = specification_效果组件[choose][1]


func _请求保存历史记录的信号() -> void:
	if 读取中:
		return
	var node:卡牌创建工具_单个卡牌设计区 = 卡牌设计区容器.get_current_tab_control()
	var data:Dictionary = save_card(node)
	if len(node.history) == 0:
		node.history.append(data)
		node.history_index = 0
		return
	else :
		if data != node.history[node.history_index]:
			if len(node.history) == node.history_index + 1:
				if len(node.history) == 20:
					node.history.remove_at(0)
					node.history.append(data)
					node.history_index = 19
				else:
					node.history.append(data)
					node.history_index = len(node.history) - 1
			else :
				node.history.resize(node.history_index + 1)
				node.history.append(data)
				node.history_index = len(node.history) - 1


func _请求读取历史记录的信号(data:Dictionary) -> void:
	var old_node:卡牌创建工具_单个卡牌设计区 = 卡牌设计区容器.get_current_tab_control()
	var index:int = 卡牌设计区容器.current_tab
	var new_node:= load_card(data)
	new_node.history = old_node.history
	new_node.history_index = old_node.history_index
	卡牌设计区容器.move_child(new_node, old_node.get_index())
	old_node.queue_free()
	卡牌设计区容器.current_tab = index


func _请求删除卡牌设计区的信号(node:卡牌创建工具_单个设计区) -> void:
	node.queue_free()
	if len(卡牌设计区容器.get_children()) == 0:
		add_单个卡牌设计区()




func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(cards_data[文件.choose_data[文件.choose_index]])
	
	_请求保存历史记录的信号()

func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
	if  data["卡名"]:
		var file = FileAccess.open(文件路径.folder卡牌() + data["卡名"] + ".json", FileAccess.WRITE)
		file.store_string(JSON.stringify(data, "   ", true, true))  # 写入内容（可为空）
		file.close()
	
	save_不可为空 = false
	读取中 = false


func _on_复制_button_up() -> void:
	var focus:Control = get_viewport().gui_get_focus_owner()
	copy_node(focus)


func _on_粘贴_button_up() -> void:
	stackup_node()


func _on_新建_button_up() -> void:
	add_单个卡牌设计区()


func _on_确认_button_up() -> void:
	push_error.visible = false
