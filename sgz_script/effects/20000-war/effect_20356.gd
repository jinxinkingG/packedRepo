extends "effect_20000.gd"

#既托主动技 #解除状态 #施加状态
#【既托】大战场，主动技。你可以指定一个己方带有负面状态的武将，将其负面状态转移到自己身上。每个回合限1次。

const EFFECT_ID = 20356
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 发动主动技
func effect_20356_start() -> void:
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

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20356_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var buffNames = Array(targetWA.get_war_debuffs())
	if buffNames.empty():
		play_dialog(actorId, "没有需要处理的负面状态", 1, 2999)
		return

	var msg = "对{0}发动【{1}】"
	
	if buffNames.size() == 1:
		msg += "\n身代其 [{2}]\n可否？"
	else:
		msg += "\n随机身代其负面状态之一\n可否？"
	msg = msg.format([
		targetWA.get_name(), ske.skill_name, buffNames[0],
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20356_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	ske.cost_war_cd(1)
	var buffNames = Array(targetWA.get_war_debuffs())
	buffNames.shuffle()
	var buffName = buffNames.pop_front()
	var turns = targetWA.get_buff(buffName)["回合数"]
	ske.remove_war_buff(targetId, buffName)
	ske.set_war_buff(actorId, buffName, turns)

	var msg = "既以袍泽相托，岂可轻弃？\n{0}之难，吾可代之".format([
		DataManager.get_actor_honored_title(targetId, me.actorId)
	])
	report_skill_result_message(ske, 2002, msg, 2)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20356_report() -> void:
	report_skill_result_message(ske, 2002)
	return
