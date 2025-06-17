extends Node
class_name 文件路径




static func csv效果组件规范() -> String:
	return "res://数据/卡牌/效果组件规范.csv"
	
static func csv效果特征规范() -> String:
	return "res://数据/卡牌/效果特征规范.csv"
	
static func csv特征_媒介_组规范() -> String:
	return "res://数据/卡牌/特征_媒介_组规范.csv"
	
static func json卡牌文件(name:String) -> String:
	return "res://数据/卡牌/卡牌/" + name + ".json"

static func tscn卡牌创建工具_效果设计区() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/效果设计区.tscn"

static func tscn卡牌创建工具_不定数量的数据节点容器() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/不定数量的数据节点容器.tscn"

static func tscn卡牌创建工具_不定数量的数据节点容器_h() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/不定数量的数据节点容器_h.tscn"

static func tscn卡牌创建工具_单个卡牌设计区() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/单个卡牌设计区.tscn"

static func folder卡牌() -> String:
	return "res://数据/卡牌/卡牌/"

static func gdcard_data_loader() -> String:
	return "res://数据/卡牌/加载数据工具/card_data_loader.gd"
	
static func png卡牌种类(name:String) -> String:
	return "res://资产/图片/卡牌/卡牌种类/" + name + ".png"

static func png卡牌(name:String) -> String:
	return "res://资产/图片/卡牌/" + name + ".png"
