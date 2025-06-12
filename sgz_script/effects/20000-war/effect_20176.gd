extends "effect_20000.gd"

#谋局主动技 #互换位置
#【谋局】大战场,主动技。你可以选择己方一名其他武将，消耗3点机动力发动。选定的己方武将与你交换位置。每回合限一次

const EFFECT_ID = 20176
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 3

func effect_20176_start()->void:
	if not assert_action_point(me.actorId, COST_AP):
		return
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(get_teammate_targets(me), msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定对手
func effect_20176_2()->void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}机动力发动【{1}】\n与{2}交换位置\n可否？".format([
		COST_AP, ske.skill_name, targetActor.get_name()
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

# 确认后播放动画
func effect_20176_3()->void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "攻敌之必守\n守敌所必攻"
	ske.play_war_animation("Strategy_Talking", 2002, targetId, msg)
	return

func on_view_model_2002()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20176_4()->void:
	var targetId = DataManager.get_env_int("目标")
	
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.swap_war_actor_positions(me.actorId, targetId)
	ske.war_report()

	map.draw_actors()
	FlowManager.add_flow("player_skill_end_trigger")
	return
