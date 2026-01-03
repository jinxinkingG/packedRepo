extends "effect_20000.gd"

#挑衅主动技 #施加状态
#【挑衅】大战场,主动技。你可选择能攻击到己方武将的1名敌将发动。令对方选择：是否对己方人员发起攻击。若对方同意，白刃战的前3个回合内，双方不能撤出战场；若对方拒绝，对之附加定止状态1回合。每个回合限1次。可对城地形目标发动。

const EFFECT_ID = 20194
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_choose_actor(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_6")
	return

func on_view_model_2004():
	wait_for_skill_result_confirmation(FLOW_BASE + "_7")
	return

func on_view_model_2005():
	wait_for_pending_message(FLOW_BASE + "_8")
	return

# 发动主动技
func effect_20194_start():
	var targets = []
	for targetId in get_combat_targets(me, true):
		var wa = DataManager.get_war_actor(targetId)
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var nearby = DataManager.get_war_actor_by_position(wa.position + dir)
			if nearby == null or nearby.disabled:
				continue
			if nearby.actorId == actorId:
				targets.append(targetId)
				break
			elif me.is_teammate(nearby):
				if not check_combat_targets([nearby.actorId]).empty():
					# 可以被技能发起白刃战
					targets.append(targetId)
					break
	if not wait_choose_actors(targets, "选择敌军发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20194_2():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	set_env("战争.挑衅目标", targetId)

	var targets = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var wa = DataManager.get_war_actor_by_position(targetWA.position + dir)
		if wa == null or wa.disabled or not targetWA.is_enemy(wa):
			continue
		targets.append(wa.actorId)
	if targets.size() == 1:
		set_env("战争.挑衅队友", targets[0])
		goto_step("4")
		return
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2001)
	return

func effect_20194_3():
	var targetId = get_env_int("目标")
	set_env("战争.挑衅队友", targetId)
	goto_step("4")
	return

func effect_20194_4():
	var targetId = get_env_int("战争.挑衅目标")
	var withId = get_env_int("战争.挑衅队友")

	ske.cost_war_cd(1)

	var msg = "{0}，可敢与{1}一战".format([
		DataManager.get_actor_naughty_title(targetId, me.actorId),
		DataManager.get_actor_honored_title(withId, me.actorId)
	])
	play_dialog(me.actorId, msg, 0, 2002)
	return

func effect_20194_5():
	var targetId = get_env_int("战争.挑衅目标")
	var withId = get_env_int("战争.挑衅队友")
	var targetWA = DataManager.get_war_actor(targetId)
	var withWA = DataManager.get_war_actor(withId)

	DataManager.battle_actors = [targetId, withId]
	targetWA.battle_init(true)
	withWA.battle_init(true)
	if targetWA.battle_morale + 10 >= withWA.battle_morale:
		var msg = "{0}无礼太甚！\n{1}接战！".format([
			DataManager.get_actor_naughty_title(me.actorId, targetId),
			DataManager.get_actor_naughty_title(withId, targetId)
		])
		play_dialog(targetId, msg, 0, 2003)
		return
	var msg = "此乃{0}诱敌之计\n全军戒备避战".format([
		DataManager.get_actor_naughty_title(me.actorId, targetId)
	])
	play_dialog(targetId, msg, 2, 2004)
	return

func effect_20194_6():
	var targetId = get_env_int("战争.挑衅目标")
	var withId = get_env_int("战争.挑衅队友")
	start_battle_and_finish(targetId, withId)
	return

func effect_20194_7():
	var targetId = get_env_int("战争.挑衅目标")
	var withId = get_env_int("战争.挑衅队友")

	ske.set_war_buff(targetId, "定止", 1)
	report_skill_result_message(ske, 2005)
	return

func effect_20194_8():
	report_skill_result_message(ske, 2005)
	return
