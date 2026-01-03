extends "effect_20000.gd"

#穷技锁定技
#【穷技】大战场，锁定技。你拥有“威”标记时，攻击不消耗机动力，改为消耗1个“威”；你没有“威”标记时，不能进行攻击。

const FLAG_EFFECT_ID = 20495
const FLAG_NAME = "威"

func on_trigger_20014() -> bool:
	var dic = DataManager.get_env_dict("战争.攻击消耗")
	var x = ske.get_skill_flags(20000, FLAG_EFFECT_ID, FLAG_NAME)
	if x <= 0:
		dic["固定"] = me.action_point + 1
		dic["原因"] = "因【{0}】\n无[威]标记，不可攻击".format([ske.skill_name])
	else:
		dic["固定"] = 0
	DataManager.set_env("战争.攻击消耗", dic)
	return false

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.fromId != actorId:
		return false
	ske.cost_skill_flags(20000, FLAG_EFFECT_ID, FLAG_NAME, 1)
	ske.war_report()
	return false
