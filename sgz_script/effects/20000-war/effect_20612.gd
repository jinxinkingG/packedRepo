extends "effect_20000.gd"

# 贵胄诱发技
#【贵胄】大战场，诱发技。非主将才能使用，你被攻击宣言时，可以选择一名营帐内的队友为目标，消耗8点机动力发动。置换你与目标队友的所处位置，并使其替代你被攻击。

const EFFECT_ID = 20612
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 8

func on_trigger_20015() -> bool:
	if me.action_point < COST_AP:
		return false
	if bf.get_defender_id() != actorId:
		return false
	var wv = me.war_vstate()
	if wv == null:
		return false
	var candidates = check_combat_targets(wv.camp_actors)
	if candidates.empty():
		return false
	return true

func effect_20612_AI_start() -> void:
	var teammates = get_camp_teammates()
	if teammates.empty():
		skill_end_clear()
		return
	DataManager.set_env("目标项", teammates[0][0].actorId)
	goto_step("selected")
	return

func effect_20612_start() -> void:
	var teammates = get_camp_teammates()
	if teammates.empty():
		var msg = "营帐无人可用"
		play_dialog(actorId, msg, 3, 2990)
		return
	var items = []
	var values = []
	for found in teammates:
		items.append("{0}（兵力：{1}）".format([
			found[0].get_name(), found[1],
		]))
		values.append(found[0].actorId)
	SceneManager.show_unconfirm_dialog("选择何人？", actorId)
	SceneManager.bind_top_menu(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_20612_selected() -> void:
	var targetId = DataManager.get_env_int("目标项")
	var msg = "{0}救我！".format([
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 3, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_go")
	return

func effect_20612_go() -> void:
	var targetId = DataManager.get_env_int("目标项")
	var pos = me.position
	var wv = me.war_vstate()
	me.camp_in()
	var wa = wv.camp_out(targetId)
	wa.position = pos
	map.draw_actors()
	wa.attach_free_dialog("… …")
	start_battle_and_finish(bf.get_attacker_id(), targetId)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20612_fight() -> void:
	var targetId = DataManager.get_env_int("目标项")
	start_battle_and_finish(bf.get_attacker_id(), targetId)
	return

# 营帐内队友按士兵数倒序
# @return [actor, soldiers]
func get_camp_teammates() -> Array:
	var ret = []
	var wv = me.war_vstate()
	if wv == null:
		return ret
	var candidates = check_combat_targets(wv.camp_actors)
	for targetId in candidates:
		var teammate = ActorHelper.actor(targetId)
		var soldiers = teammate.get_soldiers()
		var inserted = false
		for i in ret.size():
			if soldiers > ret[i][1]:
				ret.insert(i, [teammate, soldiers])
				inserted = true
				break
		if not inserted:
			ret.append([teammate, soldiers])
	return ret
