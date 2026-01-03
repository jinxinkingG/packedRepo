extends "effect_20000.gd"

# 缓兵限定技
#【缓兵】大战场，主将限定技。你为守方时才能使用。从发动时开始计算，第2日结束前，敌军不能进行用计和攻击宣言，若己方执行用计/攻击，该效果提前解除。

const EFFECT_ID = 20678
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20679

func check_AI_perform_20000() -> bool:
	# AI 第 3 天考虑发动
	var wf = DataManager.get_current_war_fight()
	if wf.date >= 3:
		return true
	return false

func effect_20678_AI_start() -> void:
	goto_step("confirmed")
	return

func effect_20678_start() -> void:
	var msg = "发动限定技【{0}】\n争取战机\n可否？".format([
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20678_confirmed() -> void:
	var msg = "{0}何逼之太急！\n虽有投诚之心，法度在上\n且容我等商议".format([
		DataManager.get_actor_honored_title(me.get_war_enemy_leader().actorId, actorId),
	])
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_response")
	return

func effect_20678_response() -> void:
	var enemyLeader = me.get_war_enemy_leader()
	var msg = "既如此 …… 暂缓用兵\n{0}早日率众反正！".format([
		DataManager.get_actor_honored_title(actorId, enemyLeader.actorId),
	])
	ske.cost_war_cd(99999)
	ske.set_war_skill_val(1, 99999, PASSIVE_EFFECT_ID)
	ske.set_war_buff(enemyLeader.actorId, "罢兵", 2)
	for wa in enemyLeader.get_teammates(false, true):
		ske.set_war_buff(wa.actorId, "罢兵", 2)
	ske.war_report()
	play_dialog(enemyLeader.actorId, msg, 0, 2999)
	return
