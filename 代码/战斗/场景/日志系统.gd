extends Node
class_name 战斗_日志系统


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus

var datasyss:Array[战斗_单位管理系统.Data_sys]
var 信息:Array[Array]



func _ready() -> void:
	event_bus.subscribe("战斗_datasys被创造", 创造了datasys)
	event_bus.subscribe("战斗_日志记录", 录入信息)


func 创造了datasys(data:战斗_单位管理系统.Data_sys) -> void:
	data.编号 = len(datasyss)
	datasyss.append(data)


func 录入信息(obj:String, fun:String, args:Array, ret) -> void:
	
	args = args.duplicate(true)
	var retarr:Array = [ret].duplicate(true)
	#_out_data(obj, fun, args, retarr[0])
	
	
	#转化成编号(args)
	#retarr = 转化成编号(retarr)
	#
	#信息.append([obj, fun, args, retarr[0]])


func 录入日志(nam:String, data:Array) -> void:
	var print_text:String
	var level:float
	
	data = data.map(func(a):
		if !a :
			return "null"
		elif a is String or a is StringName:
			return a
		elif a is int or a is float:
			return str(a)
		elif a is bool:
			if a:
				return "通过"
			else:
				return "未通过"
		elif a is 战斗_单位管理系统.Data_sys:
			return _get_nam(a)
		elif a is Array:
			var ret:String = "["
			for i in a:
				if i is 战斗_单位管理系统.Data_sys:
					ret = ret + _get_nam(i) + ", "
				else:
					ret = ret + str(i) + ", "
			ret = ret + "]"
			return ret
		else :
			assert(false))
	
	var dic:Dictionary = {
		#回合系统
		"进入回合":[0, "进入 {} 回合：{}"],
		"进入阶段":[1, "进入 {} 阶段：{}"],
		#战斗系统
		"主要阶段判断":[2, "主要阶段判断开始：{}"],
		"主要阶段打出":[3, "{} 主要阶段打出 {}"],
		"主要阶段发动":[3, "{} 主要阶段发动 {}"],
		#发动判断系统
		"单位活动回合发动判断":[21, "单位活动回合发动判断开始：{}"],
		"单位主要阶段打出判断":[21, "单位主要阶段打出判断开始：{}"],
		"单位非活动回合发动判断":[21, "单位非活动回合发动判断开始：{}"],
		"单位行动阶段打出判断":[21, "单位行动阶段打出判断开始：{}"],
		"合成构造判断":[21, "由 {} 为目标， {} 为核心， {} 为素材的合成判断 {}"],
		"卡牌发动判断":[22, "{} 在 {} 上的发动判断开始"],
		"卡牌发动判断_卡名无效检测":[23, "卡名无效检测 {}"],
		"卡牌发动判断_可用格检测":[23, "在 {} {} 上的可用格检测 {}"],
		"卡牌发动判断_连接检测":[23, "连接检测 {}"],
		"卡牌发动判断_表侧检测":[23, "表侧检测 {}"],
		"卡牌发动判断_无效检测":[23, "无效检测 {}"],
		"卡牌发动判断_自然下降检测":[23, "自然下降检测 {}"],
		"卡牌发动判断_单个效果":[23, "{} 的 {} 发动判断开始"],
		"单个效果_次数检测":[24, "次数检测 {}"],
		"单个效果_位置检测":[24, "{} 上的位置检测 {}"],
		"单个效果_启动检测":[24, "启动检测 {}"],
		"单个效果_触发检测":[24, "触发检测 {}"],
		"单个效果_状态检测":[24, "{} 中的状态检测 {}"],
		"单个效果_模式检测":[24, "{} 中的模式检测 {}"],
		"单个效果_buff检测":[24, "buff检测 {}"],
		"单个效果_cost检测":[24, "buff检测 {}"],
		"单个效果_main检测":[24, "buff检测 {}"],
		"单个效果_结束":[24, "{} 的 {} 发动判断 {}"],
		"卡牌发动判断_结束":[23, "{} 的发动判断 {}：{}"],
		"单位活动回合发动判断结束":[22, "单位活动回合发动判断结束：{}"],
		"单位主要阶段打出判断结束":[22, "单位主要阶段打出判断结束：{}"],
		"单位非活动回合发动判断结束":[22, "单位非活动回合发动判断结束：{}"],
		"单位行动阶段打出判断结束":[22, "单位行动阶段打出判断结束：{}"],
		#卡牌打出与发动系统
		"打出":[7, "{} 准备打出 {}"],
		"发动":[7, "{} 准备发动 {}"],
		"发动场上的效果":[8, "{} 准备发动场上的效果 {}：{}"],
		"选择效果并发动":[9, "{} 准备选择 {} 的 {} 之一效果并发动：{}"],
		"处理卡牌消耗":[10, "准备处理 {} 的 {} 消耗：{}"],
		#连锁系统
		"添加连锁":[10, "{} 的 {} 的 {} 添加连锁 {}：{}"],
		"请求新连锁":[4, "请求新连锁"],
		"请求进行下一连锁":[5, "请求进行下一连锁：{}"],
		"连锁处理开始":[5, "连锁处理开始"],
		"单个连锁处理开始":[6, "{} 的 {} 的 {} 的单个连锁处理开始：{}"],
		#单位控制系统
		"发动询问":[6, "发动询问：{}"],
		#发动判断处理系统
		"发动判断效果处理未通过":[25, "{} 发动判断效果处理未通过"],
		"发动判断效果处理终止":[25, "发动判断效果处理终止"],
		#效果处理系统
		"效果处理未通过":[6, "{} 效果处理未通过"],
		"效果处理终止":[6, "效果处理无效"],
		"效果处理无效":[6, "效果处理无效"],
		#最终行动系统
		"加入":[12, "{} 的 {} 加入了 {}"],
		"构造":[12, "{} 的 {} 构造到 {}"],
		"抽牌":[12, "{} 加入了"],
		"反转":[12, "{} 的 {} 反转了"],
		"无效":[12, "{} 的 {} 无效了"],
		"方向改变":[12, "{} 的 {} 方向改变了"],
		"破坏":[12, "{} 的 {} 方向破坏了"],
		"填入":[12, "{} 填入到 {} 的 {}"],
		"去除":[12, "{} 的 {} 去除了 {} 到 {}"],
		"行动打出":[12, "{} 行动打出了 {}"],
		"非行动打出":[12, "{} 非行动打出 {} 到 {}"],
		"非场上发动":[12, "{} 非场上发动 {} 到 {}"],
		#buff系统
		"单位与全部buff判断":[13, "{} 导致的buff判断：{}, {}, {}, {}"],
		"buff判断":[13, "{} 因 {} 导致的buff判断：{}, {}, {}, {}"],
		
		}
	
	level = dic[nam][0]
	print_text = dic[nam][1].format(data, "{}")
	print(str(level) + print_text)



func _out_data(p_obj:String, p_fun:String, p_args:Array, p_ret) -> void:
	var data:String
	if p_obj == "回合系统":
		if p_fun == "_回合结束":
			data = "进入回合 " + str(p_ret[0]) + "." + str(p_ret[1])
		elif p_fun == "_阶段改变的信号":
			data = "进入 " + str(p_ret) + " 阶段"
	
	elif p_obj == "最终行动系统":
		if !p_ret:
			return
		if p_fun == "加入":
			data = _get_nam(p_args[1]) + " 加入了 " + _get_nam(p_args[2].get_parent()) + " 的 " + _get_nam(p_args[2])
		elif p_fun == "构造":
			data = _get_nam(p_args[1]) + " 构造到了 " + _get_nam(p_args[2].get_parent()) + " 的 " + _get_nam(p_args[2])
		elif p_fun == "加入连锁的动画":
			data = _get_nam(p_args[0]) + " 发动了 " + _get_nam(p_args[1]) + " 的 "  + str(p_args[2] + 1) + " 效果"
		elif p_fun == "抽牌":
			data = _get_nam(p_args[0]) + " 抽牌了"
		elif p_fun == "反转":
			data = _get_nam(p_args[1]) + " 反转了"
		elif p_fun == "无效":
			data = _get_nam(p_args[1]) + " 被无效了"
		elif p_fun == "方向改变":
			data = _get_nam(p_args[1]) + " 方向改变了"
		elif p_fun == "破坏":
			data = _get_nam(p_args[1]) + " 破坏了"
		elif p_fun == "填入":
			data = _get_nam(p_args[2]) + " 填入到 " + _get_nam(p_args[1])
		elif p_fun == "流填入":
			data = _get_nam(p_args[1]) + " 流填入到 " + _get_nam(p_args[2])
		elif p_fun == "去除":
			data = _get_nam(p_args[2]) + " 去除到 " + _get_nam(p_args[3])
		
		
	elif p_obj == "卡牌打出与发动系统":
		if p_fun == "打出":
			if p_ret:
				data = _get_nam(p_args[0]) + " 打出了 " + _get_nam(p_args[1])
	
	elif p_obj == "战斗系统":
		if p_fun == "_处理卡牌消耗":
			data = _get_nam(p_args[0].get_所属life()) + " 支付了 " + _get_nam(p_args[0]) + " 的消耗"
		elif p_fun == "攻击":
			data = _get_nam(p_args[0]) + " 对 " + _get_nam(p_args[0].att_life) + p_args[2]
	
	elif p_obj == "连锁系统":
		if p_fun == "start":
			data = "连锁开始处理"
	
	elif p_obj == "发动判断系统":
		if p_fun == "卡牌发动判断":
			data = "1   " + _get_nam(p_args[0]) + " 的 " + _get_nam(p_args[1]) + " 在 " + p_args[2] + " 上 " + p_ret
		elif p_fun == "卡牌发动判断_单个效果":
			data = "1   2   " + _get_nam(p_args[0]) + " 的 " + _get_nam(p_args[1]) + " 的 " + str(p_args[1].effects.find(p_args[3])+1) + "效果 在 " + p_args[2] + " 上 " + p_ret
		elif p_fun == "_打出消耗判断":
			data = "1   " + _get_nam(p_args[0]) + " 的 " + _get_nam(p_args[1]) + "打出消耗判断" + str(p_ret)
		elif p_fun == "_发动消耗判断":
			data = "1   " + _get_nam(p_args[0]) + " 的 " + _get_nam(p_args[1]) + "发动消耗判断" + str(p_ret)
	
	elif p_obj == "战斗_发动判断系统":
		data = _get_nam(p_args[1][1]) + " 的 " + _get_nam(p_args[1][0]) + " 在 " + p_fun + " 上检测失败"
	
	elif p_obj == "战斗_效果处理系统":
		data = _get_nam(p_args[1][1]) + " 的 " + _get_nam(p_args[1][0]) + " 在 " + p_fun + " 上处理失败"
	
	elif p_obj == "buff系统":
		if p_fun == "_buff判断":
			if p_ret == 0:
				data = "因 " + p_args[1] + " 生效的 " + _get_nam(p_args[0]) + " 未通过"
			elif p_ret == 1:
				data = "因 " + p_args[1] + " 生效的 " + _get_nam(p_args[0]) + " 通过"
		elif p_fun == "create_buff":
			data = p_args[0] + " 被创建"
	
	
	
	if data:
		print(data)

func _get_nam(data_sys:战斗_单位管理系统.Data_sys) -> String:
	if !data_sys:
		return ""
	if data_sys is 战斗_单位管理系统.Effect_sys:
		return str(data_sys.序号)+"效果" + "[" + str(data_sys.编号) + "]"
	elif !data_sys is 战斗_单位管理系统.Card_sys or data_sys.appear != 0:
		return data_sys.nam + "[" + str(data_sys.编号) + "]"
	else:
		return "盖卡" + "[" + str(data_sys.编号) + "]"
