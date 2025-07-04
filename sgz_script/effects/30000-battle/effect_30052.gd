extends "effect_30000.gd"

#穿林小战场效果 #临时军种
#【穿林】大战场&小战场,锁定技。你移动经过林地形时，每步消耗的机动力不超过3。你在林地形进入白兵时，视为平军。

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	match ske.trigger_Id:
		30005:
			me.dic_other_variable["临时军种"] = "平"
		30099:
			me.dic_other_variable.erase("临时军种")
	return false
