extends "effect_20000.gd"

#定心主动技 #解除状态
#【定心】大战场,主动技。你可以指定一个有负面状态的你方武将，消耗5点机动力，随机消除该武将的一个负面状态，每回合限一次

const EFFECT_ID = 20166
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20166_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	var targets = []
	var teammates = get_teammate_targets(me)
	teammates.append(me.actorId)
	for targetId in teammates:
		var wa = DataManager.get_war_actor(targetId)
		if not wa.is_war_debuffed():
			continue
		targets.append(wa.actorId)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定队友
func effect_20166_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗 {1} 机动力\n随机清除{0}的负面状态\n可否？".format([
		targetActor.get_name(), COST_AP,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

# 执行
func effect_20166_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var buffNames = Array(targetWA.get_war_debuffs())
	if buffNames.empty():
		play_dialog(me.actorId, "没有需要处理的负面状态", 2, 2009)
		return

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	buffNames.shuffle()
	var buffName = buffNames.pop_front()
	ske.remove_war_buff(targetId, buffName)

	var targetName = DataManager.get_actor_honored_title(targetId, me.actorId)
	if targetId == me.actorId:
		targetName = "士卒"
	var msg = "{0}休慌，定心再战".format([
		targetName,
	])
	report_skill_result_message(ske, 2002, msg, 2)
	return

func effect_20166_4():
	var ske = SkillHelper.read_skill_effectinfo()
	report_skill_result_message(ske, 2002)
	return
