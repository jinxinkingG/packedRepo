extends "effect_20000.gd"

# 联进主动技
#【妄评】大战场，主动技。你可指定至多2名队友附加2回合 {恶评} 状态。每回合限1次。

const EFFECT_ID = 20641
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LIMIT = 2

func effect_20641_start() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() >= LIMIT:
		goto_step("all_selected")
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		if targetId in selected:
			continue
		targets.append(targetId)
	if targets.empty():
		if selected.empty():
			var msg = "没有合适的队友可以【{0}】".format([ske.skill_name])
			play_dialog(actorId, msg, 3, 2999)
			return
		goto_step("all_selected")
		return
	var msg = "选择队友以发动【{0}】".format([ske.skill_name])
	wait_choose_actors(targets, msg)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", true, true, FLOW_BASE + "_done")
	var selected = ske.get_war_skill_val_int_array()
	var positions = []
	for targetId in selected:
		var wa = DataManager.get_war_actor(targetId)
		if wa == null:
			continue
		positions.append(wa.position)
	map.show_color_block_by_position(positions)
	return

func effect_20641_done() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.empty():
		back_to_skill_menu()
		return
	goto_step("all_selected")
	return

func effect_20641_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var selected = ske.get_war_skill_val_int_array()
	selected.erase(targetId)
	selected.append(targetId)
	ske.set_war_skill_val(selected)
	goto_step("start")
	return

func effect_20641_all_selected() -> void:
	map.show_color_block_by_position([])
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() > LIMIT:
		selected.resize(LIMIT)
	if selected.empty():
		goto_step("start")
		return
	var names = []
	for targetId in selected:
		names.append(ActorHelper.actor(targetId).get_name())
	var msg = "对{0}发动【{1}】\n截夺其团队经验\n可否？".format([
		"、".join(names), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", true, FLOW_BASE + "_cancel")
	return

func effect_20641_cancel() -> void:
	ske.set_war_skill_val([])
	back_to_skill_menu()
	return

func effect_20641_confirmed() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() > LIMIT:
		selected.resize(LIMIT)
	var names = []
	for targetId in selected:
		ske.set_war_buff(targetId, "恶评", 2)
		names.append(DataManager.get_actor_naughty_title(targetId, actorId))
	ske.cost_war_cd(1)
	ske.war_report()

	var msg = "{0}，碌碌之辈\n我何宜在诸将军中！".format([
		"、".join(names),
	])

	report_skill_result_message(ske, 2002, msg, 0)
	selected.append(actorId)
	map.next_shrink_actors = selected
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20641_report() -> void:
	report_skill_result_message(ske, 2002)
	return
