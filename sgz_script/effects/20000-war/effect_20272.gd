extends "effect_20000.gd"

#忠存被动触发判断 #施加状态
#【忠存】大战场，锁定技。每日初始，若你方总兵力＜对方：你获得1回合“围困”状态，并在当日附加<三栖>、<忠勇>；否则，你在当日附加<冷静>。（围困：负面状态，你无法大战场撤退，且无法主动回营地。）

const EFFECT_ID = 20272

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	var buffed = me.get_buff("围困")
	if buffed["回合数"] > 0 and int(buffed["来源武将"]) == self.actorId:
		ret.append("三栖")
		ret.append("忠勇")
	else:
		ret.append("冷静")
	return ret

func on_trigger_20013()->bool:
	clear_skill_triggered_times(ske.skill_actorId, EFFECT_ID)
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	if wv.get_all_soldiers() >= enemyWV.get_all_soldiers():
		return false
	inc_skill_triggered_times(ske.skill_actorId, EFFECT_ID)
	ske.set_war_buff(ske.skill_actorId, "围困", 1)
	ske.war_report()
	FlowManager.add_flow("draw_actors")
	return false
