extends "effect_20000.gd"

#【吴子】
#吴子兵法的附加技能

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.winnerId != me.actorId:
		return false
	if me.action_point == 0 and me.battle_tactic_point > 0:
		ske.cost_war_cd(1)
		var ap = ske.change_actor_ap(me.actorId, me.battle_tactic_point)
		ske.war_report()
		var msg = "敌之虚实，吾已悉知\n（【{0}】发动\n（机动力回复{1}".format([
			ske.skill_name, ap,
		])
		me.attach_free_dialog(msg, 2)
	return false
