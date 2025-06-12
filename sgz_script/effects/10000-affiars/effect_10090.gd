extends "effect_10000.gd"

#藏卷主动技 #附加装备
#【藏卷】内政，主动技。你可从兵书/史记/春秋/六韬中任选一本，视为额外装备这本书，获得其效果。默认额外装备兵书。

const EFFECT_ID = 10090
const FLOW_BASE = "effect_" + str(EFFECT_ID)
# 兵书、史记、春秋、六韬
const OPTIONS = [0, 1, 2, 3]

func effect_10090_start()->void:
	var items = []
	var values = []
	for id in OPTIONS:
		var book = clEquip.equip(id, "道具")
		if book.subtype() != "书":
			continue
		items.append(book.name())
		values.append(book.id)
	SceneManager.show_unconfirm_dialog("选择藏卷，作为额外「装备」", actorId)
	SceneManager.bind_top_menu(items, values)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	var had = ske.affair_get_skill_val_int()
	var idx = max(0, OPTIONS.find(had))
	SceneManager.lsc_menu_top.lsc.set_selected_by_array([idx])
	wait_for_choose_item(FLOW_BASE + "_selected")
	return

func effect_10090_selected()->void:
	var selected = DataManager.get_env_int("目标项")
	if not selected in OPTIONS:
		play_dialog(-1, "未选择有效目标", 2, 2999)
		return
	ske.affair_set_skill_val(selected)
	var book = clEquip.equip(selected, "道具")
	var msg = "藏卷三千，今日读「{0}」\n（视为额外配装".format([book.name()])
	play_dialog(actorId, msg, 1, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
