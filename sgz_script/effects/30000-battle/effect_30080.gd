extends "effect_30000.gd"

#马钉技能实现
#【马钉】小战场,锁定技。整个小战场，所有骑兵单位，每移动一步，兵力-5。

func check_trigger_correct():
	if not DataManager.common_variable.has("白兵.行动单位"):
		return false

	var unitId = int(DataManager.common_variable["白兵.行动单位"])
	for bu in DataManager.battle_units:
		if bu.unitId == unitId:
			if bu.disabled:
				return false
			if bu.get_unit_type() != "骑":
				return false
			if bu.last_action_name != "移动":
				return false
			#if (self.actorId == DataManager.battle_actors[0] and bu.unit_position.x < 8) \
			#	or (self.actorId == DataManager.battle_actors[1] and bu.unit_position.x > 7):
			bu.set_hp(bu.get_hp() - 5)
	return false
