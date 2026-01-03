extends "effect_20000.gd"

# 密推主动技 #解禁计策
#【密推】大战场，限定技。消耗20体力发动。己方所有武将的被禁用的计策均解禁，回合结束时，那些计策重新禁用。

const EFFECT_ID = 20670
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_HP = 20

func check_AI_perform_20000() -> bool:
	# AI 暂不发动
	return false

func effect_20670_start() -> void:
	if actor.get_hp() <= COST_HP:
		var msg = "体力不足，须 > {0}".format([COST_HP])
		play_dialog(actorId, msg, 3, 2999)
		return

	var warActors = me.get_teammates(false, true)
	warActors.append(me)
	var somethingBanned = false
	for wa in warActors:
		for schemeName in wa.dic_skill_cd:
			if wa.dic_skill_cd[schemeName] >= 90000:
				somethingBanned = true
				break

	if not somethingBanned:
		var msg = "我军并无计策禁用\n无须【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2999)
		return

	var msg = "消耗{0}体，发动【{1}】\n全军暂时解除所有计策禁用\n可否？".format([
		COST_HP, ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20670_confirmed() -> void:
	var msg = "{0}早已备下后手\n今正其时也\n定出{1}所料！".format([
		DataManager.get_actor_self_title(actorId),
		DataManager.get_actor_naughty_title(me.get_enemy_leader().actorId, actorId),
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_settle")
	return

func effect_20670_settle() -> void:
	var recovered = []
	var warActors = me.get_teammates(false, true)
	warActors.append(me)
	for wa in warActors:
		for schemeName in wa.dic_skill_cd:
			var cd = int(wa.dic_skill_cd[schemeName])
			if cd >= 90000:
				ske.recover_disabled_scheme(wa.actorId, schemeName)
				recovered.append([wa.actorId, schemeName, cd])

	# 记住恢复了哪些
	ske.set_war_skill_val(recovered, 1)
	ske.cost_war_cd(99999)
	ske.change_actor_hp(actorId, -COST_HP)

	report_skill_result_message(ske, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20670_report() -> void:
	report_skill_result_message(ske, 2002)
	return
