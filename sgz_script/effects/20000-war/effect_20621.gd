extends "effect_20000.gd"

# 血卫主动技部分
#【血卫】大战场，主动技。你可指定1名队友，消耗你5机动力发动。直到下次对方回合结束前，指定的队友被攻击时，你可选择代替之进行战斗。不能连续两轮指定同1队友，每回合限1次。

const EFFECT_ID = 20621
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

func on_trigger_20013() -> bool:
	var lastTargetId = _get_marked_actor_id()
	ske.affair_set_skill_val(lastTargetId)
	if lastTargetId < 0:
		return false
	ske.set_war_skill_val(-1)
	return false

func effect_20621_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targets = get_teammate_targets(me)
	var lastTargetId = ske.affair_get_skill_val_int()
	targets.erase(lastTargetId)
	var msg = "选定【{0}】目标".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

func effect_20621_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗 {0} 机动力\n将【{1}】目标设定为{2}\n可否？".format([
		COST_AP, ske.skill_name, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20621_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_ap(COST_AP, true)
	ske.set_war_skill_val(targetId)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "{0}侧后，{1}自当之".format([
		DataManager.get_actor_honored_title(targetId, actorId),
		actor.get_short_name(),
	])
	play_dialog(actorId, msg, 0, 2999)
	return

func _get_marked_actor_id() -> int:
	var targetId = ske.get_war_skill_val_int(-1, -1, -1)
	if targetId < 0:
		return -1
	var wa = DataManager.get_war_actor(targetId)
	if wa == null or wa.disabled or not wa.has_position():
		return -1
	if not me.is_teammate(wa):
		return -1
	return targetId
