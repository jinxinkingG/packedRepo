extends "effect_20000.gd"

#流离诱发技
#【流离】大战场，诱发技。你被攻击的场合才能发动。对方机动力直接清零。 每回合限1次。

const EFFECT_ID = 20311
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	return

func _input_key(delta:float):
	var view_model = LoadControl.get_view_model();
	match view_model:
		2000:
			wait_for_yesno(FLOW_BASE + "_2", false)
		2001:
			wait_for_pending_message(FLOW_BASE + "_3", "")
	return

func effect_20311_AI_start():
	effect_20311_2()
	return

func effect_20311_start():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var target = me.get_battle_enemy_war_actor()
	var msg = "发动【流离】\n清空{0}的机动力\n可否？".format([
		target.get_name()
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20311_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var target = me.get_battle_enemy_war_actor()

	ske.cost_war_cd(1)
	ske.clear_actor_ap(target.actorId)
	ske.war_report()

	FlowManager.add_flow("draw_actors")
	var msg = "巾帼岂容轻慢？\n{0}既来，当知再无后路".format([
		DataManager.get_actor_naughty_title(target.actorId, me.actorId),
	])
	report_skill_result_message(ske, 2001, msg, 0)
	return

func effect_20311_3():
	var ske = SkillHelper.read_skill_effectinfo()
	report_skill_result_message(ske, 2001)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if me.actorId != bf.get_defender_id():
		return false
	var targetId = bf.get_attacker_id()
	var target = DataManager.get_war_actor(targetId)
	if target == null or target.disabled:
		return false
	return true
