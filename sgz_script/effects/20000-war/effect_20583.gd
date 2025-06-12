extends "effect_20000.gd"

# 维嫡效果
#【维嫡】大战场，诱发技。<选嫡>武将（<未指定>）「被用伤兵计」或「被用状态计」或「被攻击」时，你可替代之成为目标。每回合限1次。

const EFFECT_ID = 20583
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const XUANDI_EFFECT_ID = 10119

func on_trigger_20038() -> bool:
	var targetId = ske.affair_get_skill_val_int(XUANDI_EFFECT_ID)
	if targetId < 0 or targetId == actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if targetId != se.targetId:
		return false
	if not se.damage_soldier() and not se.damage_hp()\
		and not se.name in ["虚兵", "奇门遁甲"]:
		return false
	return true

func on_trigger_20015() -> bool:
	var targetId = ske.affair_get_skill_val_int(XUANDI_EFFECT_ID)
	if targetId < 0 or targetId == actorId:
		return false
	var bf = DataManager.get_current_battle_fight()
	if targetId != bf.get_defender_id():
		return false
	return true

func effect_20583_AI_start() -> void:
	var action = "计防"
	var who = ""
	if ske.trigger_Id == 20038:
		var se = DataManager.get_current_stratagem_execution()
		se.goback_disabled = 1
		who = ActorHelper.actor(se.fromId).get_name()
	else:
		var bf = DataManager.get_current_battle_fight()
		action = "作战"
		who = bf.get_attacker().get_name()
	var msg = "{0}休得无礼！\n（{1}发动【{2}】\n（替代{3}{4}".format([
		who, actor.get_name(), ske.skill_name,
		ActorHelper.actor(ske.actorId).get_name(), action
	])
	play_dialog(actorId, msg, 0, 3000)
	return

func on_view_model_3000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_confirmed")
	return

func effect_20583_start() -> void:
	var action = "作战"
	if ske.trigger_Id == 20038:
		action = "计策防御"
	var msg = "替代{0}进行{1}\n可否？".format([
		ActorHelper.actor(ske.actorId).get_name(), action
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20583_confirmed() -> void:
	if ske.trigger_Id == 20038:
		var se = DataManager.get_current_stratagem_execution()
		se.set_replaced_defender(actorId, ske.skill_name)
	else:
		var bf = DataManager.get_current_battle_fight()
		ske.replace_battle_defender(ske.actorId)
	ske.cost_war_cd(1)
	ske.war_report()
	LoadControl.end_script()
	return
