extends "effect_20000.gd"

#护符
#【护符】大战场,诱发技。你被伤兵类计策命中的场合，可以消耗3点机动力，发动黄巾军秘术：本次计策伤害减半，施计者兵力-100，每回合限1次。

const EFFECT_ID = 20139
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 3
const REFLECT_DAMAGE = 100

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != actorId:
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	if me == null or me.disabled:
		return false
	if me.action_point < COST_AP:
		return false
	return true

func effect_20139_AI_start():
	goto_step("start")
	return

func effect_20139_start():
	var se = DataManager.get_current_stratagem_execution()
	var damage = se.get_soldier_damage_for(actorId)
	var reduced = int(damage / 2)

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)
	ske.change_actor_soldiers(actorId, reduced)
	ske.war_report()

	var name = "之有"
	var reflected = 0
	var from = DataManager.get_war_actor(se.get_action_id(actorId))
	if from != null:
		name = from.get_name()
		reflected = int(DataManager.damage_sodiers(actorId, from.actorId, REFLECT_DAMAGE))
	var msg = "【{0}】傍身，何惧{1}".format([ske.skill_name, name])
	if reduced > 0:
		msg += "\n（计策伤害减少{0}".format([reduced])
	if reflected > 0:
		msg += "\n（{0}受到反伤，损兵{1}".format([
			from.get_name(), reflected
		])
	map.draw_actors()
	play_dialog(actorId, msg, 1, 2990)
	return
