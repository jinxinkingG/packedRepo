extends "effect_20000.gd"

# 统摄诱发技
#【统摄】大战场，诱发技。回合结束时，你可以选择1项回合内你曾进行过的下列动作之一，无视距离和机动力执行之：1.与某将进入白刃战。2.对某将用计。每回合限1次。

const EFFECT_ID = 20696
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20012() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) != actorId:
		return false
	if se.targetId < 0:
		return false
	var history = ske.get_war_skill_val_array()
	var record = ['计策', se.targetId, se.name]
	for row in history:
		if row.size() != record.size():
			continue
		if row[0] == record[0] and row[1] == record[1] and row[2] == record[2]:
			return false
	history.append(record)
	ske.set_war_skill_val(history, 1)
	return false

func on_trigger_20015() -> bool:
	if bf.get_attacker_id() != actorId:
		return false
	if bf.targetId < 0:
		return false
	var history = ske.get_war_skill_val_array()
	var record = ['白刃战', bf.targetId]
	for row in history:
		if row.size() != record.size():
			continue
		if row[0] == record[0] and row[1] == record[1]:
			return false
	history.append(record)
	ske.set_war_skill_val(history, 1)
	return false

func on_trigger_20016() -> bool:
	var history = ske.get_war_skill_val_array()
	if history.empty():
		return false
	for row in history:
		var targetId = Global.intval(row[1])
		if targetId < 0:
			continue
		var wa = DataManager.get_war_actor(targetId)
		if not me.is_enemy(wa):
			continue
		if row[0] == "计策":
			# 对计策需要检查是否仍可用计
			var se = DataManager.new_stratagem_execution(actorId, row[2], ske.skill_name)
			se.set_target(targetId)
			if not targetId in se.get_available_targets()[0]:
				continue
		# 找到任意一个可发动目标即可
		return true
	return false

func effect_20696_start() -> void:
	var history = ske.get_war_skill_val_array()
	var items = []
	var values = []
	for row in history:
		var targetId = Global.intval(row[1])
		var targetWA = DataManager.get_war_actor(targetId)
		if targetWA == null:
			continue
		if row[0] == "白刃战":
			items.append("对 {0} 发动攻击".format([targetWA.get_name()]))
			values.append(row)
		elif row[0] == "计策" and row.size() == 3:
			items.append("对 {0} 发动 {1}".format([targetWA.get_name(), row[2]]))
			values.append(row)
	if items.empty():
		goto_step("end")
		return
	var msg = "【{0}】发动\n回合结束前，可从以上动作中\n选择一个执行".format([ske.skill_name])
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected", false)
	return

func effect_20696_selected() -> void:
	var row = DataManager.get_env_array("目标项")
	if row[0] == "白刃战":
		goto_step("combat")
	if row[0] == "计策":
		goto_step("scheme")
		return
	goto_step("end")
	return

func effect_20696_combat() -> void:
	var row = DataManager.get_env_array("目标项")
	var targetId = Global.intval(row[1])
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null:
		goto_step("end")
		return
	ske.cost_war_cd(1)
	ske.mark_auto_finish_turn()	
	start_battle_and_finish(actorId, targetId)
	return

func effect_20696_scheme() -> void:
	var row = DataManager.get_env_array("目标项")
	var targetId = Global.intval(row[1])
	var targetWA = DataManager.get_war_actor(targetId)
	if targetWA == null:
		goto_step("end")
		return
	var schemeName = Global.strval(row[2])
	ske.cost_war_cd(1)
	var se = DataManager.new_stratagem_execution(actorId, schemeName, ske.skill_name)
	se.skip_redo = 1
	se.goback_disabled = 1
	se.set_target(targetId)
	ske.play_se_animation(se, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_pending_message(FLOW_BASE + "_report", FLOW_BASE + "_end")
	return

func effect_20696_report() -> void:
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2001)
	return

func effect_20696_end() -> void:
	skill_end_clear()
	return
