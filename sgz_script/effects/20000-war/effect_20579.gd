extends "effect_20000.gd"

# 复难大战场效果
#【复难】大战场，锁定技。你被攻击时，自动消耗5点机动力，抵消那次攻击。若机动力不足，则无法抵消，并使白刃战中的对方士气+X。(X=本回合你以此法抵消攻击的次数*5)

const COST_AP = 5

func on_trigger_20015() -> bool:
	var bf = DataManager.get_current_battle_fight()
	if actorId != bf.targetId:
		return false
	if me.action_point < COST_AP:
		return false
	return true

func effect_20579_AI_start() -> void:
	goto_step("start")
	return

func effect_20579_start() -> void:
	var bf = DataManager.get_current_battle_fight()
	bf.skip_execution(actorId, ske.skill_name)
	bf.war_report()

	var times = ske.get_war_skill_val_int()
	ske.set_war_skill_val(times + 1, 1)
	var info = "<y{0}>规避<y{1}>的攻击".format([
		me.get_name(), bf.get_attacker().get_name(),
	])
	ske.cost_ap(COST_AP)
	ske.append_message(info)
	ske.war_report()

	var msg = "敌势正盛，暂避一时\n（【{0}】规避{1}的攻击\n（机动力 -{2}，现为 {3}".format([
		ske.skill_name, bf.get_attacker().get_name(),
		COST_AP, me.action_point,
	])
	me.attach_free_dialog(msg, 2)
	LoadControl.end_script()
	SkillHelper.remove_current_skill_trigger()

	map.cursor.hide()
	map.clear_can_choose_actors()
	var nextFlow = "AI_before_ready"
	if me.get_controlNo() < 0:
		nextFlow = "player_ready"
	FlowManager.add_flow(nextFlow)
	return

