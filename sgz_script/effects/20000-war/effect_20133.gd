extends "effect_20000.gd"

#避祸诱发技
#【避祸】大战场,诱发技。当前回合被计策或攻击宣言锁定时，可以消耗2点机动力发动：取消此次锁定。每回合限1次。

const COST_AP = 2

func on_trigger_20015()->bool:
	if me.action_point < COST_AP:
		return false
	var bf = DataManager.get_current_battle_fight()
	return bf.get_defender_id() == me.actorId

func on_trigger_20038()->bool:
	if me.action_point < COST_AP:
		return false
	var se = DataManager.get_current_stratagem_execution()
	return se.targetId == me.actorId

func effect_20133_AI_start():
	goto_step("start")
	return

func effect_20133_start():
	var fromActor = ActorHelper.actor(ske.actorId)

	var msg = "{0}规避{1}的{2}"
	var action = "攻击"
	if ske.trigger_Id == 20038:
		var se = DataManager.get_current_stratagem_execution()
		action = se.name
		fromActor = ActorHelper.actor(se.fromId)
		# 跳过一下，不然不记录日志
		se.skip_execution(actorId, ske.skill_name)
		se.report()
	else:
		var bf = DataManager.get_current_battle_fight()
		bf.skip_execution(actorId, ske.skill_name)
		bf.war_report()
		fromActor = ActorHelper.actor(bf.get_attacker_id())
	msg = msg.format([
		me.get_name(), fromActor.get_name(), action
	])

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)
	ske.append_message(msg)
	ske.war_report()

	msg = "料敌机先，此祸可免\n（" + msg
	me.attach_free_dialog(msg, 1)
	LoadControl.end_script()
	SkillHelper.remove_current_skill_trigger()

	map.cursor.hide()
	map.clear_can_choose_actors()
	var nextFlow = "AI_before_ready"
	if me.get_controlNo() < 0:
		nextFlow = "player_ready"
	FlowManager.add_flow(nextFlow)
	return
