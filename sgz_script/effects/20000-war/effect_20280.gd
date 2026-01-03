extends "effect_20000.gd"

# 穷武主动技
#【穷武】大战场，主动技。选择你的计策列表中的1个计策为目标。你无视机动力消耗立刻使用之，若如此，直到战争结束前，禁用此计策。

const EFFECT_ID = 20280
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 兼容并覆盖主流程场景：选择用计目标
func on_view_model_121():
	var flags = _get_skill_flags()
	if flags[0] != 2:
		return
	if Global.is_action_pressed_BY():
		if not SceneManager.dialog_msg_complete(false):
			return
		LoadControl.set_view_model(-1)
		FlowManager.add_flow(FLOW_BASE + "_list")
	return

func effect_20280_start() -> void:
	_set_skill_step(0)
	var msg = "端坐使老，不如穷力一击！"
	play_dialog(actorId, msg, 0, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_list")
	return

func effect_20280_list() -> void:
	var items = []
	for scheme in me.get_stratagems():
		items.append(scheme.name)
	if items.empty():
		play_dialog(actorId, "没有任何可用计策", 3, 2999)
		return
	var msg = "使用何种计策？\n（[穷武]不消耗机动力)"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, items, 2)
	_set_skill_step(1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001() -> void:
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_20280_selected() -> void:
	var stratagem = DataManager.get_env_str("目标项")
	if stratagem == "":
		skill_end_clear()
		return
	_set_skill_step(2)
	start_scheme(stratagem)
	return

# 如果有技能标记，不消耗机动，执行后禁用计策
func on_trigger_20005() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		return false
	set_scheme_ap_cost("ALL", 0)
	return false

func on_trigger_20009() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.skill != ske.skill_name:
		return false
	var flags = _get_skill_flags()
	if flags[0] != 2:
		return false
	se.skip_redo = 1
	if se.get_action_id(actorId) != actorId:
		return false
	_set_skill_step(0)
	# 记录已使用的计策，并放入CD
	_mark_skill_used(se.name)
	me.dic_skill_cd[se.name] = 99999
	return false

# FLAG meaning: [step, used]
func _get_skill_flags()->PoolIntArray:
	var skv = SkillHelper.get_skill_variable(20000, EFFECT_ID, self.actorId)
	var flags = [0, []]
	if skv["turn"] <= 0 or typeof(skv["value"]) != TYPE_ARRAY:
		return flags
	var val = Array(skv["value"])
	if val.size() != 2 or typeof(val[1]) != TYPE_ARRAY:
		return flags
	flags[0] = int(skv["value"][0])
	flags[1] = Array(skv["value"][1])
	return flags

func _set_skill_step(step:int)->void:
	var flags = _get_skill_flags()
	flags[0] = step
	SkillHelper.set_skill_variable(20000, EFFECT_ID, actorId, flags, 1)
	return

func _mark_skill_used(stratagem:String)->void:
	var flags = _get_skill_flags()
	flags[1].append(stratagem)
	SkillHelper.set_skill_variable(20000, EFFECT_ID, actorId, flags, 1)
	return
