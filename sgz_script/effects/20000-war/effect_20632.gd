extends "effect_20000.gd"

# 孤御锁定技
#【孤御】大战场，锁定技。战争守方，回合结束阶段，若你是己方唯一的武将时（包括营帐在内）才能发动。你可无视禁用条件，选择一个已学习的计策，发动之。

const EFFECT_ID = 20632
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20016() -> bool:
	var wv = me.war_vstate()
	if wv.camp_actors.size() > 0:
		return false
	if wv.get_war_actors(false, true).size() > 1:
		return false
	return true

# 兼容并覆盖主流程场景：选择用计目标
func on_view_model_121():
	if not Global.is_action_pressed_BY():
		return
	if not SceneManager.dialog_msg_complete(false):
		return
	FlowManager.add_flow(FLOW_BASE + "_menu")
	return

func effect_20632_start() -> void:
	ske.cost_war_cd(1)
	# 技能发动后自动结束回合
	ske.mark_auto_finish_turn()
	var msg = "【{0}】触发\n可选择计策无条件发动".format([
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_menu")
	return

func effect_20632_menu() -> void:
	var items = []
	var values = []
	for scheme in me.get_stratagems():
		items.append("{0}(0)".format([scheme.name]))
		values.append(scheme.name)
	if items.empty():
		play_dialog(actorId, "没有任何可用计策", 3, 2990)
		return
	var msg = "【{0}】触发\n可选择计策无条件发动".format([
		ske.skill_name,
	])
	DataManager.set_env("对话", msg)
	SceneManager.show_unconfirm_dialog(msg, actorId)
	bind_menu_items(items, values)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected", false, true, FLOW_BASE + "_cancel")
	return

func effect_20632_selected() -> void:
	var schemeName = DataManager.get_env_str("目标项")
	var scheme = StaticManager.get_stratagem(schemeName)
	if scheme == null:
		goto_step("menu")
		return
	start_scheme(schemeName)
	return

func effect_20632_cancel() -> void:
	var msg = "放弃【{0}】发动\n可否？".format([ske.skill_name])
	play_dialog(actorId, msg, 2, 2002, true)
	return

func on_view_model_2002() -> void:
	wait_for_yesno(FLOW_BASE + "_end", false, FLOW_BASE + "_menu")
	return

func effect_20632_end() -> void:
	skill_end_clear()
	FlowManager.add_flow("player_end")
	return
