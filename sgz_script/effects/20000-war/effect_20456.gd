extends "effect_20000.gd"

#衰劫限定技
#【衰劫】大战场，限定技。若你的点数大于“私掠”武将或“私掠”武将已离场时才能发动。选择一项：A.获得“私掠”武将所有剩余机动力；B.你的机动力回满。选择完成后，移除原“私掠”标记。

const EFFECT_ID = 20456
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SILUE_EFFECT_ID = 20454

func effect_20456_start()->void:
	var targetId = ske.get_war_skill_val_int(SILUE_EFFECT_ID)
	if targetId < 0:
		var msg = "没有【私掠】标记的目标"
		play_dialog(actorId, msg, 2, 2999)
		return
	var wa = DataManager.get_war_actor(targetId)
	if wa != null and not wa.disabled and me.get_poker_point_diff(wa) <= 0:
		var msg = "点数未大过{0}\n无法发动【{1}】".format([
			wa.get_name(), ske.skill_name,
		])
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "发动【{0}】，失去私掠标记\n回满机动力\n可否？".format([
		ske.skill_name, 
	])
	if wa == null or wa.disabled or wa.action_point <= 0:
		play_dialog(actorId, msg, 2, 2000, true)
		return
	msg = "发动【{0}】，失去私掠标记\n可否？".format([
		ske.skill_name, 
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_recover")
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_choice")
	return

func effect_20456_choice()->void:
	var targetId = ske.get_war_skill_val_int(SILUE_EFFECT_ID)
	var wa = DataManager.get_war_actor(targetId)
	var msg = "选择以下效果之一："
	var options = [
		"回满机动力",
		"夺取{0} {1}机动力".format([
			wa.get_name(), wa.action_point
		])
	]
	play_dialog(actorId, msg, 2, 2002, true, options)
	return

func on_view_model_2002()->void:
	match wait_for_skill_option():
		0:
			goto_step("recover")
		1:
			goto_step("drain")
	return

func effect_20456_recover()->void:
	var targetId = ske.get_war_skill_val_int(SILUE_EFFECT_ID)
	var limit = me.get_max_action_ap()
	if me.action_point >= limit:
		var msg = "机动力充足，无须发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 2, 2999)
		return
	ske.set_war_skill_val(-1, 99999, SILUE_EFFECT_ID)
	ske.change_actor_ap(actorId, limit - me.action_point)
	ske.cost_war_cd(99999)
	ske.war_report()
	var msg = "{0}这厮势竭，没油水啦\n（机动力回满".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func effect_20456_drain()->void:
	var targetId = ske.get_war_skill_val_int(SILUE_EFFECT_ID)
	var wa = DataManager.get_war_actor(targetId)
	ske.set_war_skill_val(-1, 99999, SILUE_EFFECT_ID)
	var ap = wa.action_point
	ske.change_actor_ap(wa.actorId, -ap)
	ske.change_actor_ap(actorId, ap)
	ske.cost_war_cd(99999)
	ske.war_report()
	var msg = "{0}这厮运衰，刮个干尽\n（夺取{0} {1}机动力".format([
		ActorHelper.actor(targetId).get_name(), ap
	])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
