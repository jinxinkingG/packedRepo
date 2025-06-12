extends "effect_20000.gd"

#共患
#【共患】大战场,诱发技。你方武将被计策伤兵的场合，若你士兵数不为0，你可以消耗3点机动力发动：令本次计策伤害减免25%，然后你和该武将平摊本次计策伤害。每回合限3次。

const EFFECT_ID = 20143
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 3
const TIMES_LIMIT = 3

var dialogs = []

func on_trigger_20012()->bool:
	if me == null or me.disabled:
		return false
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != ske.actorId:
		# 只对主要计策目标触发
		return false
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false

	var wa = DataManager.get_war_actor(se.targetId)
	if not me.is_teammate(wa):
		return false

	var damage = se.get_soldier_damage_for(se.targetId)
	if damage <= 0:
		return false

	# 有兵且有机动力
	if actor.get_soldiers() <= 0 or me.action_point < COST_AP:
		return false

	# 每回合限三次
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		return false

	return true

func effect_20143_AI_start():
	goto_step("start")
	return

func effect_20143_start():
	var se = DataManager.get_current_stratagem_execution()
	var targetWA = DataManager.get_war_actor(se.targetId)
	var damage = se.get_soldier_damage_for(se.targetId)
	var reduced = int(damage / 4)
	var shared = int((damage - reduced) / 2)
	shared = min(actor.get_soldiers(), shared)

	ske.cost_war_limited_times(TIMES_LIMIT)
	ske.cost_ap(COST_AP)
	ske.change_actor_soldiers(targetWA.actorId, reduced + shared)
	ske.change_actor_soldiers(actorId, -shared)
	ske.war_report()
	var skillInfo = "{0}发动【共患】\n兵力减少{1}\n{2}计策损失降低{3}".format([
		actor.get_name(), shared, targetWA.get_name(), reduced + shared
	])
	dialogs = [
		[actorId, "{0}此难，吾当与共".format([
			DataManager.get_actor_honored_title(targetWA.actorId, actorId)
		]), 2],
		[-1, skillInfo, 2],
	]
	se.append_message(skillInfo)
	FlowManager.add_flow("draw_actors")
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if not dialogs.empty():
		LoadControl.set_view_model(2001)
		var dialog = dialogs.pop_front()
		SceneManager.show_confirm_dialog(dialog[1], dialog[0], dialog[2])
	else:
		LoadControl.end_script()
	return

func on_view_model_2001()->void:
	if Global.wait_for_confirmation(""):
		LoadControl.set_view_model(2000)
	return
