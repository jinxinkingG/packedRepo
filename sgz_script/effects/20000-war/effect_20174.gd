extends "effect_20000.gd"

#要袭主动技 #计伤
#【要袭】大战场,主动技。你可以选定6格内，一个非城地形的敌方武将，派兵突袭，机动力-2，兵-40，发动必中的[要击]。每回合限1次。

const EFFECT_ID = 20174
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 2
const COST_SOLDIERS = 40
const STRATAGEM = "要击"

func effect_20174_start() -> void:
	if actor.get_soldiers() < COST_SOLDIERS:
		var msg = "兵力不足，需 >= {0}".format([COST_SOLDIERS])
		play_dialog(me.actorId, msg, 3, 2999)
		return

	if not assert_action_point(me.actorId, COST_AP):
		return

	if not wait_choose_actors(get_enemy_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

# 已选定对手
func effect_20174_selected() -> void:
	var msg = "派出{0}敢死勇士\n消耗{1}机动力\n发动【{2}】可否？".format([
		COST_SOLDIERS, COST_AP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

# 确认后播放动画
func effect_20174_confirmed() -> void:
	var se = DataManager.new_stratagem_execution(ske.skill_actorId, STRATAGEM)
	se.set_target(DataManager.get_env_int("目标"))

	ske.cost_war_cd(1)
	ske.cost_self_soldiers(COST_SOLDIERS)
	ske.cost_ap(COST_AP, true)
	ske.war_report()
	se.perform_to_targets([se.targetId], true)

	var msg = "{0}骄兵必败\n死士何在！".format([
		DataManager.get_actor_naughty_title(se.targetId, self.actorId),
	])
	ske.play_se_animation(se, 2002, msg, 0)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20174_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return
