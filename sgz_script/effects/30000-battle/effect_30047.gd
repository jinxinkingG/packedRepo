extends "effect_30000.gd"

#长兵技能实现
#【长兵】小战场,锁定技。你的步兵和骑兵攻击距离变为1~2

func check_trigger_correct():
	var unitId = get_env_int("白兵.初始化单位ID")
	var bu = get_battle_unit(unitId)
	if bu == null or bu.disabled:
		return false
	if bu.leaderId != self.actorId:
		return false
	if not bu.get_unit_type() in ["步", "骑"]:
		return false
	if bu.dic_combat.has("长兵"):
		return false
	bu.dic_combat["长兵"] = 1
	bu.dic_combat["近战距离"] = 2
	return false
