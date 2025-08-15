extends BaseStateMachine
class_name 战斗_回合系统_StateMachine


var event_bus : CoreSystem.EventBus = CoreSystem.event_bus


func _ready() -> void:
	# 添加主要状态
	add_state(&"初始", 初始State.new())
	add_state(&"战斗", 战斗State.new())
	add_state(&"抽牌", 抽牌State.new())
	add_state(&"开始", 开始State.new())
	add_state(&"行动", 行动State.new())
	add_state(&"主要", 主要State.new())
	add_state(&"结束", 结束State.new())


##切换到下一个状态
func swicth_next() -> void:
	current_state.swicth_next()



## 初始状态
class 初始State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"战斗")


## 战斗状态
class 战斗State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"抽牌")

## 抽牌状态
class 抽牌State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"开始")

## 开始状态
class 开始State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"行动")

## 行动状态
class 行动State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"主要")

## 主要状态
class 主要State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"结束")

## 结束状态
class 结束State extends BaseState:
	var event_bus : CoreSystem.EventBus = CoreSystem.event_bus
	func _enter(_msg := {}) -> void:
		pass
	
	func swicth_next() -> void:
		switch_to(&"战斗")
	
	func _exit() -> void:
		event_bus.push_event("战斗_回合结束")
