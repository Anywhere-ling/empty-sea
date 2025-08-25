extends Control

@onready var grid_container: GridContainer = %GridContainer
@onready var x: SpinBox = %x
@onready var y: SpinBox = %y
@onready var _1: SpinBox = %"1"
@onready var _2: SpinBox = %"2"
@onready var h_slider: HSlider = %HSlider


func _physics_process(delta: float) -> void:
	#var arr:Array = 线段(Vector2(x.value,y.value), true, h_slider.value, _1.value, _2.value)
	var arr:Array = 方形取格(Vector2(x.value,y.value), _1.value, _2.value)
	for i in grid_container.get_children():
		i.disabled = false
	for i in arr:
		get_场上(i.x, i.y).disabled = true
	
	#queue_redraw()
	pass
	#print(方形取格(Vector2(3, 3), 1, 2))



func get_场上(x:int, y:int):
	if x<1 or x>5 or y<1 or y>5:
		return null
	var ind:int = ((y-1)*5)+x-1
	var poss = grid_container.get_children()
	return poss[ind]


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

func 线段(origin: Vector2, is_positive:bool, angle_deg: float, d1: float, d2: float) -> Array:
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
	#反转
	if !is_positive:
		vec2_d1 = Vector2(-vec2_d1.x, vec2_d1.y)
		vec2_d2 = Vector2(-vec2_d2.x, vec2_d2.y)
	#加上原点
	vec2_d1 = origin + vec2_d1
	vec2_d2 = origin + vec2_d2
	#格相交
	var ret:Array
	for x in range(1,6):
		for y in range(1,6):
			if 相交判断(Vector2(x,y), vec2_d1, vec2_d2):
				ret.append(Vector2(x,y))
	
	a = vec2_d1
	b = vec2_d2
	return ret

var a:Vector2
var b:Vector2

func _draw() -> void:
	a = a*100 - Vector2(50,50)
	b = b*100 - Vector2(50,50)
	draw_line(a, b, Color.RED)



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
			if !v1.is_equal_approx(v3) and !v2.is_equal_approx(v3):
				ret = true
			else :
				if 交点 == 3:
					ret = true
				else:
					交点 += 1
	
	if Rect2(origin1, Vector2(1,1)).has_point(d1):
		ret = true
	if Rect2(origin1, Vector2(1,1)).has_point(d2):
		ret = true
	
	return ret
	







# 给定原点、角度、两端距离，返回经过的格子（Vector2(i,j)，1-based）
func cells_from_segment(origin: Vector2, angle_deg: float, d1: float, d2: float, rows:int=5, cols:int=5) -> Array:
	var result: Array = []
	var seen := {}

	# 方向向量（列=x，行=y）
	var rad = deg_to_rad(angle_deg)
	var dir = Vector2(sin(rad), -cos(rad)) # 注意：0度是向上
	
	# 起止点（浮点坐标）
	var p0 = origin + dir * d1
	var p1 = origin + dir * d2
	
	# 离散化 DDA
	var dx = p1.x - p0.x
	var dy = p1.y - p0.y
	var steps = int(max(abs(dx), abs(dy)))  # 用较大分量做步长
	if steps == 0:
		steps = 1
	
	var x_inc = dx / steps
	var y_inc = dy / steps
	var x = p0.x
	var y = p0.y
	
	for i in range(steps + 1):
		var cx = int(round(x))
		var cy = int(round(y))
		if cx >= 1 and cx <= cols and cy >= 1 and cy <= rows:
			var key = str(cx) + "," + str(cy)
			if not seen.has(key):
				result.append(Vector2(cx, cy))
				seen[key] = true
		x += x_inc
		y += y_inc
	
	return result
