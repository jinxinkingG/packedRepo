extends "effect_20000.gd"

#排异主动技
#【排异】大战场，主动技。你通过<争功>获得的其他队友的主经验累计达到1500/3000/6000时，各增加1次发动本技能的机会。发动的回合结束时，你至多可挑选1名阴阳面的队友一起进入额外回合，只在此额外回合中：你视为拥有<奋困>，并对你和该队友之外的敌我将领均附加沉默状态。

const EFFECT_ID = 20452
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const PASSIVE_EFFECT_ID = 20451

const EXP_LEVELS = [1500, 3000, 6000, -1]

func effect_20452_start()->void:
	if DataManager.is_extra_war_round():
		var msg = "额外回合中\n不可发动【{0}】".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var flags = get_skill_flags()
	if flags.size() == 3 and flags[2] == 1:
		var msg = "本回合已发动【{0}】".format([
			ske.skill_name
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var val = ske.get_war_skill_val_int(PASSIVE_EFFECT_ID)
	var times = 0
	for i in EXP_LEVELS.size():
		if val >= EXP_LEVELS[i]:
			times += 1
	var left = times
	if flags.size() == 3:
		left = times - flags[1]
	var msg = "已累计争功{0}经验\n".format([
		val,
	])
	if left <= 0:
		if times < 3:
			msg += "达到{0}可发动【{1}】"
			msg = msg.format([
				EXP_LEVELS[times], ske.skill_name,
			])
		else:
			msg += "已发动{0}次【{1}】\n不可继续发动".format([
				flags.size(), ske.skill_name
			])
		play_dialog(actorId, msg, 2, 2999)
	else:
		msg += "可发动{0}次【{1}】\n剩余{2}次，是否发动？".format([
			 times, ske.skill_name, left
		])
		play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20452_2()->void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.has_side():
			targets.append(targetId)
	if targets.empty():
		DataManager.set_env("目标", -1)
		goto_step("3")
		return
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_actor(FLOW_BASE + "_3")
	return

func effect_20452_3():
	var targetId = DataManager.get_env_int("目标")
	var msg = "将独自进入额外回合"
	DataManager.add_actor_to_extra_round(actorId)
	if targetId >= 0:
		msg = "将与{0}一起进入额外回合".format([
			ActorHelper.actor(targetId).get_name()
		])
		DataManager.add_actor_to_extra_round(targetId)
	var flags = get_skill_flags()
	# 标记的格式：<选择的队友，已发动次数，发动状态>
	# 发动状态：0：无效，1：已发动，2：已在额外回合生效
	flags[0] = targetId
	flags[1] = flags[1] + 1
	flags[2] = 1
	ske.set_war_skill_val(flags, 99999)
	play_dialog(actorId, msg, 2, 2999)
	if targetId == StaticManager.ACTOR_ID_JIANGWEI:
		if actorId == StaticManager.ACTOR_ID_ZHONGHUI:
			var targetWA = DataManager.get_war_actor(targetId)
			msg = "天下俊才，无出公右\n今日之势，公何以教我？"
			me.attach_free_dialog(msg, 2)
			msg = "君算无遗策，大功既立\n何不仿陶朱公，从赤松游？"
			me.attach_free_dialog(msg, 1, 20000, targetId)
			msg = "公真知心者，余人岂知我志\n为今之道，或未尽于此也"
			me.attach_free_dialog(msg, 2)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return

func get_skill_flags()->PoolIntArray:
	var flags = ske.get_war_skill_val_int_array()
	if flags.size() != 3:
		flags = [0, 0, 0]
	return flags
