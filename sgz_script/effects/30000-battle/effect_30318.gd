extends "effect_30000.gd"

# 并骑锁定技
#【并骑】小战场，锁定技。你默认8骑，第3～6回合内，你的骑兵行动次数+1。

func on_trigger_30003() -> bool:

	var data = {
		"兵种数量": {"骑": 8},
		"分配顺序": ["骑"],
	}
	# 固定阵型 14/15
	var formation = 11514
	if actorId == bf.get_attacker_id():
		data["攻方阵型"] = formation
	else:
		data["守方阵型"] = formation

	bf.update_extra_formation_setting(actorId, ske.skill_name, "特殊", data)

	return false

func on_trigger_30009() -> bool:
	var turn = bf.turns()
	if turn < 3 or turn > 6:
		return false
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() != "骑":
			continue
		bu.wait_action_times = min(3, bu.get_action_times() + 1)
	return false

