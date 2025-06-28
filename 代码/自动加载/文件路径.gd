extends Node





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
	
static func tscn卡牌创建工具_单位_单个卡牌设计区() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/单位_单个卡牌设计区.tscn"

static func tscn卡牌创建工具_装备_单个卡牌设计区() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/装备_单个卡牌设计区.tscn"

static func tscn卡牌创建工具_buff_单个卡牌设计区() -> String:
	return "res://代码/自动加载/工具(不自动加载/卡牌创建工具/ui/buff_单个卡牌设计区.tscn"

static func folder卡牌() -> String:
	return "res://数据/卡牌/卡牌/"
	
static func folder单位() -> String:
	return "res://数据/卡牌/单位/"

static func folderbuff() -> String:
	return "res://数据/卡牌/buff/"

static func folder装备() -> String:
	return "res://数据/卡牌/装备/"

static func gdcard_data_loader() -> String:
	return "res://数据/卡牌/加载数据工具/card_data_loader.gd"
	
static func png卡牌种类(name:String) -> String:
	return "res://资产/图片/卡牌/卡牌种类/" + name + ".png"

static func png卡牌(name:String) -> String:
	return "res://资产/图片/卡牌/" + name + ".png"

static func png_nocard(name:String) -> String:
	return "res://资产/图片/单位/nocard/" + name + ".png"

static func png_character(name:String) -> String:
	return "res://资产/图片/单位/character/" + name + ".png"

static func png_test() -> String:
	return "res://资产/图片/test.png"
