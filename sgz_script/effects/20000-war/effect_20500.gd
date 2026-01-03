extends "effect_20000.gd"

#纳贿诱发效果
#【纳贿】大战场，诱发技。你方其他武将受到计策伤害的场合，发动：对方需选择，是否将100～500金交给你，若对方给金，则你的永久标记[金]+该金数，且该回合，你周围6格内的你方武将被用计时，施计方命中率+X（X=交给你的金/25）；否则，你恢复该队友本次计策伤害一半的士兵数。每个回合限1次。

const EFFECT_ID = 20500
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_SCENE_ID = 10000
const FLAG_EFF_ID = 10023 # 在「金猪」中存储标记
const FLAG_NAME = "金"

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.succeeded <= 0:
		return false
	if se.get_action_id(actorId) < 0:
		return false

	var damaged = se.get_all_damaged_targets()
	if damaged.empty():
		return false
	if actorId in damaged and damaged.size() == 1:
		return false
	for targetId in damaged:
		var wa = DataManager.get_war_actor(targetId)
		if me.is_teammate(wa):
			se.skip_redo = 1
			return true

	return false

func effect_20500_AI_start():
	goto_step("start")
	return

func effect_20500_start():
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var gold = Global.get_random(1, 5) * 100
	ske.set_war_skill_val(gold, 1)
	var msg = "{0}端的好计\n未知更肯破费否\n({2}索贿{1}".format([
		DataManager.get_actor_honored_title(fromId, actorId),
		gold, actor.get_name(),
	])
	if me.get_controlNo() < 0:
		msg += "，可否？"
		play_dialog(actorId, msg, 1, 2000, true)
	else:
		play_dialog(actorId, msg, 1, 3000)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_yes", false, FLOW_BASE + "_no")
	return

func on_view_model_3000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_maybe")
	return

func effect_20500_yes()->void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var gold = ske.get_war_skill_val_int()
	var wa = DataManager.get_war_actor(fromId)
	var wv = wa.war_vstate()
	if wv.money < gold:
		var msg = "金不足 ……"
		play_dialog(fromId, msg, 3, 2001)
		return

	ske.change_wv_gold(-gold, wv)
	ske.add_skill_flags(FLAG_SCENE_ID, FLAG_EFF_ID, FLAG_NAME, gold)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "{0}美意，笑纳了\n（[{1}]增加{2}\n（{3}军失去资金{2}->{4}".format([
		DataManager.get_actor_honored_title(fromId, actorId),
		FLAG_NAME, gold, wv.get_leader().get_name(), wv.money,
	])
	play_dialog(actorId, msg, 1, 2990)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_no")
	return

func effect_20500_no()->void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var damage = se.get_total_damage()
	ske.set_war_skill_val(0, 0)
	var recover = damage
	recover = ske.add_actor_soldiers(actorId, recover)
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "哼！{0}如此铿吝\n真当我看不破汝计？\n（{1}士兵 +{2}".format([
		DataManager.get_actor_naughty_title(fromId, actorId),
		actor.get_name(), recover
	])
	play_dialog(actorId, msg, 1, 2999)
	return

# AI 决策
func effect_20500_maybe()->void:
	var se = DataManager.get_current_stratagem_execution()
	var fromId = se.get_action_id(actorId)
	var gold = ske.get_war_skill_val_int()
	var wa = DataManager.get_war_actor(fromId)
	var wv = wa.war_vstate()
	if wv.money < gold:
		goto_step("no")
		return
	if Global.get_rate_result(50):
		goto_step("no")
		return
	goto_step("yes")
	return
