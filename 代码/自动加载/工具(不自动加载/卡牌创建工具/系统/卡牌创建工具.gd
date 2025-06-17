extends Control
class_name 卡牌创建工具

'''
用于创建卡牌的gui工具
希望实现功能：
	1.读取所有已创建的卡牌文件（csv）：
		有一个总目录以便读取
		为读取的每一张卡创建一个选项
		当点击选项时显示卡牌信息
	2.创建的卡牌文件（csv）：
		规范卡牌，以规范文件（csv）为基础创建选项
		通过选项创建卡牌
		保存
	3.修改规范文件（csv）

'''

@onready var 卡牌设计区容器: TabContainer = %卡牌设计区容器
@onready var 组件: 卡牌创建工具_带搜索的选择器 = %组件
@onready var 特征: 卡牌创建工具_带搜索的选择器 = %特征
@onready var 标点: 卡牌创建工具_带搜索的选择器 = %标点
@onready var 特: 卡牌创建工具_带搜索的选择器 = %特
@onready var 媒: 卡牌创建工具_带搜索的选择器 = %媒
@onready var 组: 卡牌创建工具_带搜索的选择器 = %组
@onready var 文件: 卡牌创建工具_带搜索的选择器 = %文件
@onready var 简介: Label = %简介
@onready var 提供焦点: Button = %提供焦点
@onready var 路径: Label = %路径
@onready var 存储区数据: Label = %存储区数据
@onready var 复制储存区: VBoxContainer = %复制储存区
@onready var push_error: PanelContainer = %push_error




#规范文件的加载数据
var specification_效果组件:Dictionary
var specification_效果特征:Dictionary
var specification_效果标点:Dictionary = {
	"特征":["效果的特征，用于检测", "括号"],
}

var specification_特征:Dictionary
var specification_媒介:Array
var specification_组:Array

var cards_data:Dictionary

var copy_node_data:#储存复制数据
	set(value):
		copy_node_data = value
		存储区数据.text = str(copy_node_data)
var 读取中:bool = false
var save_不可为空:bool = false




func _ready() -> void:
	_加载卡牌数据()
	_加载规范文件并处理数据()
	print(specification_效果组件)
	print(specification_效果特征)
	_将数据写入选择器()
	组件.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特征.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	标点.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	特.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	媒.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组.确认按钮被按下.connect(_选择器的确认按钮被按下的信号)
	组件.请求显示简介.connect(_选择器的请求显示简介的信号)
	特征.请求显示简介.connect(_选择器的请求显示简介的信号)
	标点.请求显示简介.connect(_选择器的请求显示简介的信号)
	特.请求显示简介.connect(_选择器的请求显示简介的信号)
	
	add_单个卡牌设计区()


func _加载卡牌数据() -> void:
	var names:Array = DatatableLoader.other_data["卡名总表"]
	for i:String in names:
		cards_data[i] = DatatableLoader.get_dic_data("card_data", i)


func _加载规范文件并处理数据() -> void:
	var file_效果特征:= FileAccess.open(文件路径.csv效果特征规范(), FileAccess.READ)
	var file_效果组件:= FileAccess.open(文件路径.csv效果组件规范(), FileAccess.READ)
	var file_特征_媒介_组:= FileAccess.open(文件路径.csv特征_媒介_组规范(), FileAccess.READ)
	
	#特征_媒介_组
	file_特征_媒介_组.get_csv_line()
	while not file_特征_媒介_组.eof_reached():
		var arr:Array = file_特征_媒介_组.get_csv_line()
		# 跳过空行或无效行
		if arr.size() == 0 or (arr.size() == 1 and arr[0] == ""):
			continue
		
		if arr[0] != "":
			specification_特征[arr[0]] = arr[1]
		if arr[2] != "":
			specification_媒介.append(arr[2])
		if arr[3] != "":
			specification_组.append(arr[3])
	
	
	#效果特征
	file_效果特征.get_csv_line()
	while not file_效果特征.eof_reached():
		var arr:Array = file_效果特征.get_csv_line()
		# 跳过空行或无效行
		if arr.size() == 0 or (arr.size() == 1 and arr[0] == ""):
			continue
		#去掉空格
		arr.filter(func(a):return !a is String and !a == [])

		specification_效果特征[arr[0]] = arr[1]
	
	#效果组件
	file_效果组件.get_csv_line()
	while not file_效果组件.eof_reached():
		var arr:Array = file_效果组件.get_csv_line()
	
		#去掉空格
		arr = arr.filter(func(a):return !a == "")
		
		# 跳过空行或无效行
		if arr.size() == 0 or (arr.size() == 1 and arr[0] == ""):
			continue

		#开始处理
		var new_arr:Array
		for index1:int in len(arr):
			#第一次分割
			var i1:PackedStringArray = arr[index1].split("/" , false)
			#如果无法分割
			if len(i1) == 1:
				new_arr.append(i1[0])
				continue
			
			var new_i1:Array
			for index2:int in len(i1):
				#第二次分割
				var i2:Array = i1[index2].split("_" , false)
				#如果无法分割
				if len(i2) == 1:
					new_i1.append(i2[0])
					continue
				
				new_i1.append(i2)
			new_arr.append(new_i1)
		
		specification_效果组件[new_arr[0]] = new_arr

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







func _add_node(node:BoxContainer, s:String) -> Control:
	if specification_效果标点.has(s):
		if specification_效果标点[s][1] == "括号":
			return _add_node_括号(node, s)
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
	return 

func _add_node_括号(node:卡牌创建工具_不定数量的数据节点容器, s:String) -> Label:
	var node1:= Label.new()
	node1.text = s + "["
	var node2:= Label.new()
	node2.text = "]" + s
	
	node.add_child_node(node1)
	var a := 提供焦点.duplicate(12)
	a.visible = true
	node1.add_child(a)
	node.add_child_node(node2)
	var a2 := 提供焦点.duplicate(12)
	a2.visible = true
	node2.add_child(a2)
	return node2

func _add_node_文本(node:Container, 简介:String) -> Label:
	var node1:= Label.new()
	node1.text = 简介
	if node is 卡牌创建工具_不定数量的数据节点容器:
		node.add_child_node(node1)
	if node is 卡牌创建工具_不定数量的数据节点容器_h:
		node.add_child_node(node1)
	if node is HBoxContainer:
		node.add_child(node1)
	var a := 提供焦点.duplicate(12)
	a.visible = true
	node1.add_child(a)
	return node1

func _add_node_任意输入(node:Container, 简介:String = "", default:String = "") -> LineEdit:
	var node1:= LineEdit.new()
	node1.placeholder_text = 简介
	node1.text = default
	if node is 卡牌创建工具_不定数量的数据节点容器:
		node.add_child_node(node1)
	if node is HBoxContainer:
		node.add_child(node1)
	node1.size_flags_horizontal = SIZE_EXPAND_FILL
	return node1

func _add_node_数字输入(node:Container, 简介:String = "", default:String = "") -> SpinBox:
	var node1:= SpinBox.new()
	node1.prefix = 简介
	if default != "":
		node1.value = int(default)
	if node is 卡牌创建工具_不定数量的数据节点容器:
		node.add_child_node(node1)
	if node is HBoxContainer:
		node.add_child(node1)
	return node1

func _add_node_单选(node:Container, 简介:String = "", default:String = "", 选项:Array = []) -> OptionButton:
	var node1:= OptionButton.new()
	if 简介 != "":
		node1.add_separator(简介)
	if default != "":
		node1.add_item(default)
		node1.select(0)
	for i:String in 选项:
		node1.add_item(i)
	if node is 卡牌创建工具_不定数量的数据节点容器:
		node.add_child_node(node1)
	if node is HBoxContainer:
		node.add_child(node1)
	return node1

func _add_node_多选(node:Container, 简介:String = "", default:String = "", 选项:Array = []) -> 卡牌创建工具_不定数量的数据节点容器_h:
	var node1 := load(文件路径.tscn卡牌创建工具_不定数量的数据节点容器_h()).instantiate() as 卡牌创建工具_不定数量的数据节点容器_h
	node1.tooltip_auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	node1.tooltip_text = "多选"
	if node is 卡牌创建工具_不定数量的数据节点容器:
		node.add_child_node(node1)
	if node is HBoxContainer:
		node.add_child(node1)
	node1.size_flags_horizontal = SIZE_EXPAND_FILL
	#node1.size_flags_vertical = SIZE_SHRINK_BEGIN
	node1.选项卡.visible = true
	node1.加.visible = true
	if 简介 != "":
		node1.选项卡.add_separator(简介)
	for i:String in 选项:
		node1.选项卡.add_item(i)
	return node1

func _add_node_组件(node:卡牌创建工具_不定数量的数据节点容器, s:String) -> HBoxContainer:
	var node1:= HBoxContainer.new()
	add_child(node1)#临时储存
	node1.size_flags_horizontal = SIZE_EXPAND_FILL
	
	var arr: = specification_效果组件[s].duplicate(true) as Array
	for i:int in len(arr):
		if i == 0:
			#效果名
			_add_node_文本(node1, s)
		elif i == 1:
			#简介
			pass
		else:
			if !arr[i] is Array:
				#只有简介
				_add_node_任意输入(node1, arr[i])
			else :
				var arr2:Array = arr[i]
				var 简介:String = arr2[0]
				var default:String = ""
				arr2.remove_at(0)
				if arr2.has("可为空"):
					default = "-1"
				for i2 in arr2:
					if !i2 is Array:
						if i2 == "数字":
							_add_node_数字输入(node1, 简介, default)
					else:
						if i2[0] == "选项":
							i2.remove_at(0)
							_add_node_单选(node1, 简介, default, _将带波浪线的选项展开(i2))
						if i2[0] == "多选项":
							i2.remove_at(0)
							_add_node_多选(node1, 简介, default, _将带波浪线的选项展开(i2))
	remove_child(node1)
	node.add_child_node(node1)
	return node1

func _将带波浪线的选项展开(arr:Array) -> Array:
	var arr1:Array = arr.duplicate(true)
	var new_arr:Array
	for i:String in arr1:
		if i.find("~") != -1:
			var has_文字:String = ""
			for i2:String in ["对象"]:
				if i.begins_with(i2):
					has_文字 = i2
					i = i.erase(0 , len(i2))
					continue
			var arr2:Array = i.split("~" , true)
			arr2[0] = int(arr2[0])
			arr2[1] = int(arr2[1])
			arr2 = range(arr2[0] , arr2[1] + 1)
			arr2 = arr2.map(func(a): return has_文字 + str(a))
			new_arr.append_array(arr2)
		else :
			new_arr.append(i)
	return new_arr



func save_card(card_node:卡牌创建工具_单个卡牌设计区) -> Dictionary:
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
	for i:卡牌创建工具_效果设计区 in card_node.效果.get_children():
		var i1:卡牌创建工具_不定数量的数据节点容器 = i.get_child(1)
		if len(i1.get_children()) > 2:
			arr.append(_翻译效果data(i1))
	card_data["效果"] = arr
	
	
	
	
	return card_data

#处理符号
func _翻译效果data(node:卡牌创建工具_不定数量的数据节点容器) -> Array:
	var arr:Array = []#返回值
	var temp_string:String = ""#正在处理的符号
	var temp_dic:Dictionary = {}#处理符号时使用
	for ind:int in len(node.get_children()) - 2:
		var node1:Control = node.get_children()[ind]
		var data:Variant = _tran_node_to_data(node1)
		
		if data.find("[") != -1:
			data = data.replace("[", "")
			assert(!temp_dic.keys().has(data) , "已经有该括号")
			temp_string = data
			temp_dic[data] = [data]
		
		elif data.find("]") != -1:
			data = data.replace("]", "")
			assert(temp_string == data , "没有正括号，或者顺序错误")
			if len(temp_dic.keys()) > 1:
				temp_dic[temp_dic.keys()[-2]].append(temp_dic[temp_dic.keys()[-1]])
				temp_string = temp_dic.keys()[-2]
			else:
				arr.append(temp_dic[temp_dic.keys()[-1]])
				temp_string = ""
			temp_dic.erase(temp_string)
		else:
			if temp_string:
				temp_dic[temp_string].append(data)
			else :
				arr.append(data)
			
	return arr

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
		ret = node.value
	elif node is OptionButton :
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
	node.sp.value = card_data["sp"]
	node.mp.value = card_data["mp"]
	node.文本.text = card_data["文本"]
	
	for i:String in card_data["特征"]:
		_add_node(node.特征, i)
	for i:String in card_data["媒介"]:
		_add_node(node.媒介, i)
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
	if data is String:
		if specification_效果标点.keys().has(data) or specification_效果特征.keys().has(data):
			_add_node_文本(node, data)
	if data is Array:
		#效果
		if specification_效果组件.keys().has(data[0]):
			var node1:= _add_node_组件(node, data[0])
			#写入数据
			var arr:Array = node1.get_children()
			for i:int in len(data):
				if i == 0:
					continue
				_write_data_to_node(data[i], arr[i])
		#括号标点
		elif specification_效果标点.keys().has(data[0]):
			if specification_效果标点[data[0]][1] == "括号":
				var focus2:Control = _add_node_括号(node, data[0])
				data.remove_at(0)
				for i in data:
					_翻译效果node(i, node, focus2)
				focus.grab_focus()


#写入数据到单个节点
func _write_data_to_node(data, node:Control) -> void:
	if node is LineEdit:
		assert(data is String, "数据类型错误")
		node.text = data
	elif node is SpinBox:
		assert(data is int, "数据类型错误")
		node.value = data
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
	print(copy_node_data)
		

#粘贴
func stackup_node() -> void:
	var node:卡牌创建工具_单个卡牌设计区 = 卡牌设计区容器.get_current_tab_control()
	if !copy_node_data :
		return
	#
	var path_arr:Array = 路径.text.split("/")
	assert(path_arr[1] in ["卡名 ", "种类 ", "sp    ", "mp   ", "特征 ", "媒介 ", "组     ", "文本 ", "效果"], "路径不匹配")
	if len(path_arr) < 3 or path_arr[1] == "效果" and len(path_arr) < 4:
		if path_arr[1] == "卡名 ":
			node.卡名.text = copy_node_data
		elif path_arr[1] == "种类":
			var index:int = -2
			for i:int in node.种类.item_count:
				if node.种类.get_item_text(i) == copy_node_data:
					index = i
			assert(index != -2, "不在选项中")
			node.种类.select(index)
		elif path_arr[1] == "sp    ":
			node.sp.value = copy_node_data
		elif path_arr[1] == "mp   ":
			node.mp.value = copy_node_data
		elif path_arr[1] == "文本 ":
			node.文本.text = copy_node_data
		
		elif path_arr[1] == "特征 ":
			for i:String in copy_node_data:
				_add_node(node.特征, i)
		elif path_arr[1] == "媒介 ":
			for i:String in copy_node_data:
				_add_node(node.媒介, i)
		elif path_arr[1] == "组     ":
			for i:String in copy_node_data:
				_add_node(node.组, i)
		
		elif path_arr[1] == "效果":
			var node1:卡牌创建工具_效果设计区 = node.效果.get_child(-1)
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


func _请求删除卡牌设计区的信号(node:卡牌创建工具_单个卡牌设计区) -> void:
	node.queue_free()
	if len(卡牌设计区容器.get_children()) == 0:
		add_单个卡牌设计区()


func _on_删除_button_up() -> void:
	var focus:Control = get_viewport().gui_get_focus_owner()
	var node:Control = focus.get_parent()
	#多选
	if node is Label and node.get_parent() is 卡牌创建工具_不定数量的数据节点容器_h:
		node.get_parent().remove_child_node(node)
		return
	#焦点在最左边的label
	if focus and node.tooltip_text == "基础数据节点容器的名字":
		for i in node.get_parent().get_child(1).get_children():
			i.get_parent().remove_child_node(i)
	
	node = _find_parent(focus)
	if node:
		node.get_parent().remove_child_node(node)


func _on_加载_button_up() -> void:
	if 文件.choose_index != -1:
		load_card(cards_data[文件.choose_data[文件.choose_index]])


func _on_保存_button_up() -> void:
	save_不可为空 = true
	读取中 = true#阻止保存历史记录
	
	var data:Dictionary = save_card(卡牌设计区容器.get_current_tab_control())
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
