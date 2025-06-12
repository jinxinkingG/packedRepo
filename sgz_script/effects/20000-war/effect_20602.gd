extends "effect_20000.gd"

# 潜行主动技
#【潜行】大战场，主动技。若你已处于｛潜行｝状态，可消耗2点机动力提前解除；否则，可消耗6点机动力，进入3回合｛潜行｝状态。解除 {潜行} 状态时，此技能 CD 2回合。

const EFFECT_ID = 20602
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 6
const COST_AP_DISMISS = 2
const BUFF = "潜行"
const TURNS = 3

func on_trigger_20013() -> bool:
	if ske.get_war_skill_val_int() <= 0:
		return false
	if me.get_buff(BUFF)["回合数"] <= 0:
		ske.set_war_skill_val(0)
		# BUFF 被动消失
		ske.cost_war_cd(2)
	return false

func get_cost_ap() -> int:
	if me.get_buff(BUFF)["回合数"] > 0:
		return COST_AP_DISMISS
	return COST_AP

func effect_20602_start() -> void:
	if me.get_buff(BUFF)["回合数"] > 0:
		goto_step("dismiss_start")
		return
	if not assert_action_point(actorId, COST_AP):
		return
	var msg = "消耗 {0} 机动力\n进入「{1}」状态 {2} 回合\n可否？".format([
		COST_AP, BUFF, TURNS,
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20602_confirmed() -> void:
	ske.cost_ap(COST_AP, true)
	ske.set_war_buff(actorId, BUFF, 3)
	# 设置标记，用以辅助判断被动 BUFF 消失后的 CD
	ske.set_war_skill_val(1)
	ske.war_report()

	var msg = "宁以待时"
	map.draw_actors()
	play_dialog(actorId, msg, 2, 2999)
	return

func effect_20602_dismiss_start() -> void:
	if not assert_action_point(actorId, COST_AP_DISMISS):
		return
	var msg = "消耗 {0} 机动力\n解除「{1}」状态\n可否？".format([
		COST_AP_DISMISS, BUFF
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_dismiss_confirmed")
	return

func effect_20602_dismiss_confirmed() -> void:
	ske.cost_ap(COST_AP_DISMISS, true)
	ske.cost_war_cd(2)
	ske.remove_war_buff(actorId, BUFF)
	# 取消标记
	ske.set_war_skill_val(0)
	ske.war_report()

	var msg = "战机已现！"
	map.draw_actors()
	play_dialog(actorId, msg, 0, 2999)
	return
