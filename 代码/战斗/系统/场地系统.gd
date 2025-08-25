extends Node

var poss:Array


func start() -> void:
	for i in 5:
		for i2 in 5:
			var pos := 战斗_单位管理系统.Card_pos_sys.new("场上")
			pos.glo_x = i2 + 1
			if i2 + 1 > 3:
				pos.x = 6 - pos.glo_x
			else :
				pos.x = pos.glo_x
			pos.y = i + 1
			poss.append(pos)


func get_连接场上(life:战斗_单位管理系统.Life_sys) -> Array:
	var old_ret:Array
	var ret:Array = [null]
	
	var o_x:int = 5
	if life.is_positive:
		o_x = 1
	
	while old_ret != ret:
		old_ret = ret
		ret = []
		
		for i:战斗_单位管理系统.Card_pos_sys in life.cards_pos["场上"]:
			if i.glo_x == o_x:
				ret.append(i)
			elif get_相邻场上(i).any(func(a):return old_ret.has(a)):
				ret.append(i)
	
	return ret
	


func get_可攻击场上(life:战斗_单位管理系统.Life_sys) -> Array:
	var 范围:Array
	if life.att_mode.has("直接攻击") or life.att_mode == []:
		范围.append_array([Vector2(1,0),Vector2(2,0),Vector2(3,0),Vector2(4,0)])
	
	if !life.is_positive:
		for i in 范围:
			i.x = i.x * -1
	
	var ret:Array
	var life_pos:Array = life.cards_pos["场上"]
	for pos in life_pos:
		var posi:Vector2 = Vector2(pos.glo_x, pos.y)
		for i in 范围:
			var att_pos = get_场上2(posi + i)
			if !att_pos or !att_pos.get_parent() or life == att_pos.get_parent():
				continue
			if !ret.has(att_pos):
				ret.append(att_pos)
	
	return ret


func get_可用场上(life:战斗_单位管理系统.Life_sys, 区:String, mp:int = 0) -> Array:
	var life_pos:Array = life.cards_pos["场上"]
	var x:int
	var y:int = mp
	if y < 1 or y > 5:
		y = 0
	if 区 in ["手牌"]:
		x = 0
	elif 区 in ["绿区", "白区"]:
		x = 1
	elif 区 in ["蓝区"]:
		x = 2
	elif 区 in ["红区"]:
		x = 3
	else:
		assert(false)
	
	var 媒介区:Array
	if !y:
		for pos in life_pos:
			if pos.x == x:
				媒介区.append(pos)
	else :
		for pos in life_pos:
			if pos.x == x and pos.y == y:
				媒介区.append(pos)
	
	var ret:Array
	if !y:
		ret = 媒介区
	else:
		for pos in 媒介区:
			for pos2 in get_相邻场上(pos):
				if !pos2.get_parent() or pos2.appear in [-1,0,2]:
					ret.append(pos2)
	if !x:
		ret = []
		for pos in poss:
			if pos.glo_x == 1 and life.is_positive:
				ret.append(pos)
			elif pos.glo_x == 5 and !life.is_positive:
				ret.append(pos)
	
	ret = get_按appear筛选格(ret, [-1,0,2])
	
	return ret


func get_按appear筛选格(arr:Array, appear:Array) -> Array:
	var ret:Array
	for pos in arr:
		if pos.appear in appear:
			ret.append(pos)
	
	return ret


func get_相邻场上(pos:战斗_单位管理系统.Card_pos_sys) -> Array:
	if pos.nam != "场上":
		return []
	var x:int = pos.glo_x
	var y:int = pos.y
	
	var ret:Array
	ret.append(get_场上(x+1,y))
	ret.append(get_场上(x-1,y))
	ret.append(get_场上(x,y+1))
	ret.append(get_场上(x,y-1))
	
	while ret.has(null):
		ret.erase(null)
		
	return ret


func get_场上(x:int, y:int) -> 战斗_单位管理系统.Card_pos_sys:
	if x<1 or x>5 or y<1 or y>5:
		return null
	var ind:int = ((y-1)*5)+x-1
	return poss[ind]

func get_场上2(vec:Vector2) -> 战斗_单位管理系统.Card_pos_sys:
	var x = vec.x
	var y = vec.y
	if x<1 or x>5 or y<1 or y>5:
		return null
	var ind:int = ((y-1)*5)+x-1
	return poss[ind]




##origin:原点，is_positive:单位方向, angle_deg:角度, d1:端点1, d2:端点2
func 线段取格(origin: Vector2, angle_deg: float, d1: float, d2: float) -> Array:
	#标准化
	angle_deg = posmod(angle_deg, 360.0)
	#转换向量
	var vec2_angle: = Vector2.from_angle(deg_to_rad(angle_deg))
	var cos_angle = posmod(angle_deg, 90.0)
	if cos_angle > 45:
		cos_angle = 90 - cos_angle
	vec2_angle = vec2_angle/cos(deg_to_rad(cos_angle))
	
	var vec2_d1: = vec2_angle * d1
	var vec2_d2: = vec2_angle * d2
	#加上原点
	vec2_d1 = origin + vec2_d1
	vec2_d2 = origin + vec2_d2
	#格相交
	var ret:Array
	for x in range(1,6):
		for y in range(1,6):
			if 相交判断(Vector2(x,y), vec2_d1, vec2_d2):
				ret.append(Vector2(x,y))
	
	return ret


func 相交判断(origin: Vector2, d1:Vector2, d2:Vector2) -> bool:
	var ret:bool = false
	#12
	#34
	var origin1: Vector2 = origin + Vector2(-0.5, -0.5)
	var origin2: Vector2 = origin + Vector2(0.5, -0.5)
	var origin3: Vector2 = origin + Vector2(-0.5, 0.5)
	var origin4: Vector2 = origin + Vector2(0.5, 0.5)
	
	var 交点:int = 0
	for v1: Vector2 in [origin1, origin4]:
		for v2: Vector2 in [origin2, origin3]:
			var v3 = Geometry2D.segment_intersects_segment(d1, d2, v1, v2)
			if !v3 :
				continue
			#忽视有且仅有一个角相交
			if !v1.is_equal_approx(v3) and !v2.is_equal_approx(v3):
				ret = true
			else :
				if 交点 == 3:
					ret = true
				else:
					交点 += 1
	#端点所在
	if Rect2(origin1, Vector2(1,1)).has_point(d1):
		ret = true
	if Rect2(origin1, Vector2(1,1)).has_point(d2):
		ret = true
	
	return ret


func 方形取格(origin: Vector2, d1: int, d2: int) -> Array:
	var ret:Array
	var d3:int
	var d4:int
	d1 = abs(d1)
	d2 = abs(d2)
	if d1 >= d2:
		d3 = d1
		d4 = d2
	else :
		d3 = d2
		d4 = d1
	
	for x in range(-d3, d3+1):
		for y in range(-d3, d3+1):
			var x1 = origin.x + x
			var y1 = origin.y + y
			if x1<1 or x1>5 or y1<1 or y1>5:
				continue
			ret.append(Vector2(x1,y1))
	
	for x in range(1-d4, d4):
		for y in range(1-d4, d4):
			var x1 = origin.x + x
			var y1 = origin.y + y
			if x1<1 or x1>5 or y1<1 or y1>5:
				continue
			ret.erase(Vector2(x1,y1))
	
	return ret


func 两点取角(origin:Vector2, target:Vector2) -> float:
	var d3:Vector2 = Vector2(target.x, target.y) - Vector2(origin.x, origin.y)
	return rad_to_deg(d3.angle())


func 视角化(origin:Vector2, mode:Array, target:Vector2) -> Array:
	var ret:Array
	if mode.has("反"):
		ret.append(Vector2((origin.x*2) - target.x, target.y))
	if mode.has("正"):
		if !ret.has(target):
			ret.append(target)
	return ret
