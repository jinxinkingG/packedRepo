extends "effect_10000.gd"

#妄尊主动技
#【妄尊】内政，君主主动技。立刻增加3枚命令书，但下个月，你方势力的命令书只有0枚（强迫结束）。每两个月限用1次。若你方势力城池不小于10座，则改为立即增加6枚命令书。

const EFFECT_ID = 10102
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10102_start()->void:
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var extra = 3
	if clCity.all_cities([vstateId]).size() >= 10:
		extra = 6
	ske.affair_cd(2)
	DataManager.orderbook += extra
	var skipping = DataManager.get_env_dict("内政.跳过内政")
	skipping[str(vstateId)] = DataManager.year * 12 + DataManager.month + 1
	DataManager.set_env("内政.跳过内政", skipping)
	var msg = "吾家四世三公，门人无数\n何令不可行？\n（【{0}】命令书 +{1}".format([
		ske.skill_name, extra
	])
	play_dialog(actorId, msg, 1, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_10102_end()->void:
	var vstateId = DataManager.vstates_sort[DataManager.vstate_no]
	var reporter = DataManager.get_max_property_actorId("政", vstateId, [actorId])
	var msg = "主公有命，无所不从\n只不免劳动吏民……\n（下月将跳过内政"
	play_dialog(reporter, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
