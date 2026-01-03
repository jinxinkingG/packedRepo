extends "effect_20000.gd"

#离魂主动技 #施加状态
#【离魂】大战场,限定技。指定1名男性武将为目标，消耗你10点机动力发动。你与目标同时定止8~10回合。若你或目标其中一个离开战场，留下的另一人解除定止状态。可对城地形目标发动。

const EFFECT_ID = 20177
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10
const STOP_ROUND_MIN = 8
const STOP_ROUND_MAX = 10

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func on_view_model_2004():
	wait_for_pending_message(FLOW_BASE + "_6")
	return

# 发动主动技
func effect_20177_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	var targets = []
	for targetId in get_enemy_targets(me, true):
		var actor = ActorHelper.actor(targetId)
		if not actor.is_male():
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择对手发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定对手
func effect_20177_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}机动力发动【离魂】\n与{1}各定止8-10回合\n可否？".format([
		COST_AP, targetActor.get_name()
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20177_3():
	var msg = "{0}蒲柳之姿\n恐未合将军之意？".format([
		DataManager.get_actor_self_title(me.actorId),
	])
	play_dialog(me.actorId, msg, 3, 2002)
	return

func effect_20177_4():
	var targetId = get_env_int("目标")
	play_dialog(targetId, "这……", 2, 2003)
	return

func effect_20177_5():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(99999)
	ske.set_war_skill_val(targetId, 99999)
	ske.cost_ap(COST_AP, true)
	ske.set_war_buff(ske.skill_actorId, "定止", Global.get_random(STOP_ROUND_MIN, STOP_ROUND_MAX))
	ske.set_war_buff(targetId, "定止", Global.get_random(STOP_ROUND_MIN, STOP_ROUND_MAX))
	
	report_skill_result_message(ske, 2004)
	return

func effect_20177_6():
	report_skill_result_message(ske, 2004)
	return
