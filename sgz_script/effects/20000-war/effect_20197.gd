extends "effect_20000.gd"

#命替主动技 #交换位置 #施加状态
#【命替】大战场,限定技。你选择一个对方武将（非城地形），消耗10点机动力，你与其交换位置，那之后，你获得1回合“定止”状态。

const EFFECT_ID = 20197
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 10

# 发动主动技
func effect_20197_start():
	if not assert_action_point(me.actorId, COST_AP):
		return false

	if me.get_buff_label_turn(["禁止移动"]) > 0:
		LoadControl._error("已被定止，无法发动【命替】")
		return false

	var targets = get_enemy_targets(me)
	if not wait_choose_actors(targets, "选择对手发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定对手
func effect_20197_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗{0}机动力发动【命替】\n与{1}交换位置\n自身定止，可否？".format([
		COST_AP, targetActor.get_name()
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

# 确认后播放动画
func effect_20197_3():
	var targetId = get_env_int("目标")
	var msg = "{0}明珠蒙尘\n何不及早来投？".format([
		DataManager.get_actor_honored_title(targetId, me.actorId)
	])
	ske.play_war_animation("Strategy_Talking", 2002, targetId, msg)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

# 执行
func effect_20197_4():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(99999)
	ske.cost_ap(COST_AP, true)
	ske.swap_war_actor_positions(me.actorId, targetId)
	ske.set_war_buff(me.actorId, "定止", 1)

	report_skill_result_message(ske, 2003)
	return

func on_view_model_2003():
	wait_for_pending_message(FLOW_BASE + "_5")
	return

func effect_20197_5():
	report_skill_result_message(ske, 2003)
	return
