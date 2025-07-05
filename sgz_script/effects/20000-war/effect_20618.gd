extends "effect_20000.gd"

# 联进主动技
#【联进】大战场，主动技。你可指定至多3名队友，令其各消耗10机动力，你的武/统/知临时增加 X*10，至多以此法增至90。X=所选队友数量。每回合限1次。

const EFFECT_ID = 20618
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LIMIT = 3
const COST_AP = 10
const BUFFED = 10

func on_trigger_20013() -> bool:
	var selected = ske.get_war_skill_val_int_array()
	if selected.empty():
		return false
	ske.change_war_power(actorId, -BUFFED * selected.size(), true)
	ske.change_war_wisdom(actorId, -BUFFED * selected.size(), true)
	ske.change_war_leadership(actorId, -BUFFED * selected.size(), true)
	ske.set_war_skill_val([])
	ske.war_report()
	return false

func effect_20618_start() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if not selected.empty():
		var msg = "刀已出鞘，箭已在弦\n当速进军！\n（不可重复提升属性"
		play_dialog(actorId, msg, 0, 2999)
		return
	goto_step("choose")
	return

func effect_20618_choose() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() >= LIMIT:
		goto_step("all_selected")
		return
	var targets = []
	for targetId in get_teammate_targets(me):
		if targetId in selected:
			continue
		var wa = DataManager.get_war_actor(targetId)
		if wa.action_point < COST_AP:
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

func effect_20618_done() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.empty():
		back_to_skill_menu()
		return
	goto_step("all_selected")
	return

func effect_20618_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var selected = ske.get_war_skill_val_int_array()
	selected.erase(targetId)
	selected.append(targetId)
	ske.set_war_skill_val(selected)
	goto_step("choose")
	return

func effect_20618_all_selected() -> void:
	map.show_color_block_by_position([])
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() > LIMIT:
		selected.resize(LIMIT)
	if selected.empty():
		goto_step("choose")
		return
	var names = []
	for targetId in selected:
		names.append(ActorHelper.actor(targetId).get_name())
	var msg = "对{0}\n发动【{1}】，加强我部\n可否？".format([
		"、".join(names), ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", true, FLOW_BASE + "_cancel")
	return

func effect_20618_cancel() -> void:
	ske.set_war_skill_val([])
	back_to_skill_menu()
	return

func effect_20618_confirmed() -> void:
	var selected = ske.get_war_skill_val_int_array()
	if selected.size() > LIMIT:
		selected.resize(LIMIT)
	var names = []
	ske.change_war_power(actorId, BUFFED * selected.size(), true)
	ske.change_war_wisdom(actorId, BUFFED * selected.size(), true)
	ske.change_war_leadership(actorId, BUFFED * selected.size(), true)
	for targetId in selected:
		ske.change_actor_ap(targetId, -COST_AP, false)
		names.append(DataManager.get_actor_honored_title(targetId, actorId))
	ske.cost_war_cd(1)
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)

	var msg = "{0}\n相助一臂，我部先发！".format([
		"、".join(names),
	])

	report_skill_result_message(ske, 2002, msg, 0)
	selected.append(actorId)
	map.next_shrink_actors = selected
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20618_report() -> void:
	report_skill_result_message(ske, 2002)
	return
