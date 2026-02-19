extends "effect_20000.gd"

# 拟化效果
#【拟化】大战场，主动技。①选择自身“武、统、知、政、胆”中的两项，交换二者的数值，每回合限1次。②若你交换的两项数值均为99，则你的机动力+10。

const EFFECT_ID = 20713
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_BONUS = 10

func effect_20713_start() -> void:
	var items = []
	var values = []
	for prop in ["武", "统", "知", "政", "胆"]:
		var val = actor._get_attr_int(prop)
		items.append("[{0}]：  {1}".format([prop, val]))
		values.append(prop)
	var msg = "选择两项，交换数值\n按「开始」键确认"
	SceneManager.show_unconfirm_dialog(msg, actorId)
	SceneManager.bind_top_menu(items, values, 1)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	var menu = SceneManager.lsc_menu_top
	var lsc = menu.lsc
	var options = DataManager.get_env_array("列表值")
	var selected = ske.get_war_skill_val_array()
	var indexes = []
	for i in options.size():
		if options[i] in selected:
			indexes.append(i)
	lsc.set_selected_by_array(indexes)

	if Global.is_action_pressed_BY() \
		and SceneManager.dialog_msg_complete():
		LoadControl.set_view_model(-1)
		back_to_skill_menu()
		return
	if selected.size() == 2 \
		and Input.is_action_just_pressed("EMU_START"):
		goto_step("selected")
		return
	if not Global.wait_for_choose_item("", ""):
		return
	var option = DataManager.get_env_str("目标项")
	var idx = options.find(option)
	if idx < 0:
		return
	if option in selected:
		selected.erase(option)
	elif selected.size() < 2:
		selected.append(option)
	ske.set_war_skill_val(selected, 1)
	LoadControl.set_view_model(2000)
	return

func effect_20713_selected() -> void:
	var selected = ske.get_war_skill_val_array()
	if selected.size() != 2:
		goto_step("start")
		return
	var pa = str(selected[0])
	var pb = str(selected[1])
	var msg = "交换「{0}」、「{1}」\n可否？".format([
		pa, pb,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20713_confirmed() -> void:
	var selected = ske.get_war_skill_val_array()
	if selected.size() != 2:
		goto_step("start")
		return
	var pa = str(selected[0])
	var pb = str(selected[1])
	var va = actor._get_attr_int(pa)
	var vb = actor._get_attr_int(pb)
	ske.change_war_attr(actorId, pa, vb - va)
	ske.change_war_attr(actorId, pb, va - vb)
	if va == vb and va == 99:
		ske.change_actor_ap(actorId, AP_BONUS)
	ske.cost_war_cd(1)

	var msg = "不过数值而已 ……"
	report_skill_result_message(ske, 2002, msg, 1)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20713_report() -> void:
	report_skill_result_message(ske, 2002)
	return
