extends "effect_20000.gd"

#试剑限定技 #禁用技能
#【试剑】大战场，主将限定技。选择对方主将的一个技能，本场战争禁用之。

const EFFECT_ID = 20346
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_item(FLOW_BASE + "_2")
	return

func on_view_model_2009():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func on_view_model_3009():
	wait_for_pending_message(FLOW_BASE + "_AI_2", "AI_before_ready")
	return

func check_AI_perform_20000()->bool:
	var wv = me.war_vstate()
	if wv == null:
		return false
	var enemyWV = wv.get_enemy_vstate()
	if enemyWV == null:
		return false
	var enemyLeaderId = enemyWV.main_actorId
	if enemyLeaderId < 0:
		return false
	if get_valuable_skill_list(enemyLeaderId).empty():
		return false
	return true

func effect_20346_AI_start():
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	var enemyLeaderId = enemyWV.main_actorId
	var skills = Array(get_valuable_skill_list(enemyLeaderId))
	if Global.get_rate_result(50):
		skills.shuffle()
	set_env("目标项", skills[0])
	goto_step("2")
	return

func effect_20346_AI_2():
	report_skill_result_message(ske, 3009)
	return

func effect_20346_start():
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	var enemyLeaderId = -1
	if enemyWV != null:
		enemyLeaderId = enemyWV.main_actorId
	if enemyLeaderId < 0:
		play_dialog(me.actorId, "不可发动", 2, 2009)
		return
	var enemyLeader = ActorHelper.actor(enemyLeaderId)

	var msg = "禁用{0}的哪个技能？".format([
		enemyLeader.get_name()
	])
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	var skills = get_valuable_skill_list(enemyLeaderId)
	if skills.empty():
		msg = "{0}没有可以禁用的技能".format([
			enemyLeader.get_name()
		])
		play_dialog(me.actorId, msg, 2, 2009)
		return
	bind_menu_items(skills, skills, 1)
	LoadControl.set_view_model(2000)
	return

# 已选定技能，执行
func effect_20346_2():
	var wv = me.war_vstate()
	var enemyWV = wv.get_enemy_vstate()
	var enemyLeaderId = enemyWV.main_actorId

	var skill = get_env_str("目标项")

	ske.cost_war_cd(99999)
	ske.ban_war_skill(enemyLeaderId, skill, 99999)

	var msg = "{0}，可知吾剑利否？".format([
		DataManager.get_actor_naughty_title(enemyLeaderId, me.actorId),
	])
	var nextViewModel = 2009
	if me.get_controlNo() < 0:
		nextViewModel = 3009
	report_skill_result_message(ske, nextViewModel, msg, 0)
	return

func effect_20346_3():
	report_skill_result_message(ske, 2009)
	return
