extends "effect_20000.gd"

# 连杀限定技
#【连杀】大战场，限定技。你可指定1名敌将，对之发起攻击，之后你的机动力清零。若以此法造成敌将被击杀/俘虏，重置该技能冷却。

const EFFECT_ID = 20681
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform_20000() -> bool:
	# AI 暂不发动
	return false

func effect_20681_start() -> void:
	if not wait_choose_actors(get_combat_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20681_selected() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "消耗全部机动力\n对{0}发动【{1}】\n可否？".format([
		ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20681_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	ske.set_war_skill_val(targetId)
	ske.cost_ap(me.action_point, true)
	ske.cost_war_cd(99999)
	start_battle_and_finish(actorId, targetId)
	return
