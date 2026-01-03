extends "effect_20000.gd"

# 扬旌主动技
#【扬旌】大战场，锁定技。以一名队友为目标发动效果①，同一回合可再发动效果②，每回合该流程限1次。
# 效果①：将目标的机动力转移给你。
# 效果②：将你的所有机动力转移给目标。

const EFFECT_ID = 20707
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20707_start():
	var teammates = get_teammate_targets(me)
	if not wait_choose_actors(teammates, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20707_selected() -> void:
	var flag = ske.get_war_skill_val_int()
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	var msg = "获得{0}的全部机动力（{1}），可否？".format([
		targetWA.get_name(),
		targetWA.action_point,
	])
	if flag > 0:
		msg = "将全部机动力（{0}）交给给{1}，可否？".format([
			me.action_point,
			targetWA.get_name(),
		])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20707_confirmed() -> void:
	var flag = ske.get_war_skill_val_int()
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = DataManager.get_actor_honored_title(targetId, actorId)
	var mood = 2
	if flag > 0:
		var ap = me.action_point
		ap = ske.change_actor_ap(actorId, -ap)
		ske.change_actor_ap(targetId, abs(ap))
		ske.cost_war_cd(1)
		msg += "，扬旗进军！"
		mood = 0
	else:
		var ap = targetWA.action_point
		ap = ske.change_actor_ap(targetId, -ap)
		ske.change_actor_ap(actorId, abs(ap))
		ske.set_war_skill_val(1, 1)
		msg += "，且待旗号"
	report_skill_result_message(ske, 2002, msg, mood)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20707_report() -> void:
	report_skill_result_message(ske, 2002)
	return
