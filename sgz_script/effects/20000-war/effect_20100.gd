extends "effect_20000.gd"

#天妒效果实现
#【天妒】大战场,锁定技。只在战争中，你的体力上限-10，伤兵类计策命中率+10%，每次计策随机减少所需机动力。

const EFFECT_ID = 20100

func on_trigger_20005()->bool:
	if get_env_int("计策.消耗.仅对比") > 0:
		return false
	var cost = get_env_int("计策.消耗.所需")
	# 最多减到 1/3，期望比智神差
	var reduce = int(ceil(cost/3.0)) + 1
	reduce = DataManager.pseduo_random_war() % reduce
	if reduce <= 0:
		return false
	set_scheme_ap_cost("ALL", cost - reduce)
	var msg = "【{0}】减少计策消耗{1}".format([
		ske.skill_name, reduce,
	])
	# 此时已经是实际扣减了，所以 se 已经创建
	var se = DataManager.get_current_stratagem_execution()
	se.append_result(ske.skill_name, msg, reduce, me.actorId)
	# 不需要单独做技能汇报
	return false

func on_trigger_20013()->bool:
	if ske.get_war_skill_val_int() > 0:
		return false
	ske.set_war_skill_val(1, 99999)
	ske.change_actor_max_hp(actorId, -10)
	actor.set_hp(min(actor.get_max_hp(), actor.get_hp()))
	ske.war_report()
	return false

func on_trigger_20017()->bool:
	change_scheme_chance(me.actorId, ske.skill_name, 10)
	return false
