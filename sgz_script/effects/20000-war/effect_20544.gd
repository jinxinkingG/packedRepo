extends "effect_20000.gd"

#喝棒主动技
#【喝棒】大战场，主动技。你发现你方其他武将处于｛定止｝状态时，你对其当头一棒！使其体力-5，并解除其｛定止｝状态。该武将体＞10才能使用，每回合限1次。

const EFFECT_ID = 20544
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_HP = 5

# 发动主动技
func effect_20544_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		if wa.get_buff("定止")["回合数"] <= 0:
			continue
		if wa.actor().get_hp() <= 10:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有合适的发动对象"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20544_2() -> void:
	var targetId = DataManager.get_env_int("目标")

	var msg = "对{0}发动【{1}】\n令其体力 -{2}\n并摆脱定止，可否？".format([
		ActorHelper.actor(targetId).get_name(),
		ske.skill_name, COST_HP
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20544_3() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(1)
	ske.change_actor_hp(targetId, -COST_HP)
	ske.remove_war_buff(targetId, "定止")
	ske.war_report()

	var msg = "{0}何故犹疑不进\n须知军法无情！".format([
		DataManager.get_actor_naughty_title(targetId, actorId)
	])
	report_skill_result_message(ske, 2002, msg, 0, actorId, false)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20544_report():
	report_skill_result_message(ske, 2002)
	return
