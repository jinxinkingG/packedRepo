extends "effect_20000.gd"

#微醺效果实现
#【微醺】大战场,锁定技。每回合你前2次使用伤兵类计策时，取对方“武，统，知，政”中最弱属性为智力计算成功率

const TIMES_LIMIT = 2

func on_trigger_20017()->bool:
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		return false
	if DataManager.get_env_int("计策.ONCE.执行") > 0:
		# 实际执行，需要扣减次数
		if not ske.cost_war_limited_times(TIMES_LIMIT):
			return false
	var targetId = DataManager.get_env_int("计策.ONCE.计策目标")
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled:
		return false
	var wisdom = wa.actor().get_wisdom()
	wisdom = min(wisdom, wa.actor().get_power())
	wisdom = min(wisdom, wa.actor().get_politics())
	wisdom = min(wisdom, wa.actor().get_leadership())
	DataManager.set_env("计策.ONCE.目标智力", wisdom)
	var se = DataManager.get_current_stratagem_execution()
	var msg = "【{0}】视{1}智力为{2}".format([
		ske.skill_name, wa.get_name(), wisdom
	])
	# 每个目标汇报一次
	var key = ske.skill_name + str(targetId)
	se.append_result(key, msg, wisdom, targetId, true)
	return false
