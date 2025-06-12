extends "effect_20000.gd"

#既托主动技 #解除状态 #施加状态
#【既托】大战场，主动技。你可以指定一个己方带有负面状态的武将，将其负面状态转移到自己身上。每个回合限1次。

const EFFECT_ID = 20356
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
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
func effect_20356_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	var targets = []
	for targetId in get_teammate_targets(me):
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
func effect_20356_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "消耗 {1} 机动力\n随机转移{0}的负面状态\n可否？".format([
		targetActor.get_name(), COST_AP,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

# 执行
func effect_20356_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var buffNames = Array(targetWA.get_war_debuffs())
	if buffNames.empty():
		play_dialog(me.actorId, "没有需要处理的负面状态", 2, 2009)
		return

	ske.cost_war_cd(1)
	buffNames.shuffle()
	var buffName = buffNames.pop_front()
	var turns = targetWA.get_buff(buffName)["回合数"]
	ske.remove_war_buff(targetId, buffName)
	ske.set_war_buff(me.actorId, buffName, turns)

	var msg = "既以袍泽相托，岂可轻弃？\n{0}之难，吾可代之".format([
		DataManager.get_actor_honored_title(targetId, me.actorId)
	])
	report_skill_result_message(ske, 2002, msg, 2)
	return

func effect_20356_4():
	report_skill_result_message(ske, 2002)
	return
