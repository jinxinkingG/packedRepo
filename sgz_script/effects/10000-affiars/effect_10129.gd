extends "effect_10000.gd"

# 悯施主动技
#【悯施】内政，主动技。立刻不消耗命令书执行一次[赏赐民众]指令，且此次提升的统治度数值翻倍。每月限1次。

const EFFECT_ID = 10129
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10129_start() -> void:
	var city = clCity.city(DataManager.player_choose_city)
	if city.get_loyalty() >= 100:
		var msg = "民众均已心悦诚服"
		play_dialog(actorId, msg, 1, 2999)
		return

	var props = ["金", "米"]
	var limits = [
		min(city.get_gold(), 100),
		min(city.get_rice(), 100)
	]
	var digits = [1, 1]
	DataManager.common_variable["赏赐数量"] = [0, 0]
	SceneManager.show_input_numbers("抚恤民众，多少金米?", props, limits, digits)
	SceneManager.show_cityInfo(true)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_multiple_number_input(FLOW_BASE + "_decided")
	return

func effect_10129_decided() -> void:
	var numbers = DataManager.get_env_int_array("多项数值")
	var msg = "施予民众 {0}金 {1}米\n可否？".format([
		numbers[0], numbers[1]
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10129_confirmed() -> void:
	ske.affair_cd(1)
	var city = clCity.city(DataManager.player_choose_city)
	var vstateId = city.get_vstate_id()
	var numbers = DataManager.get_env_int_array("多项数值")
	var money = numbers[0]
	var rice = numbers[1]
	var satrap = city.get_leader()
	var added = satrap.get_moral() * (money + rice) / 2000 * Global.get_random(10, 16) / 10
	added *= 2
	var timesBuff = SkillRangeBuff.max_for_city("赏赐民众倍率", city.ID)
	if timesBuff != null:
		added = int(added * timesBuff.effectTagVal)
	added = city.add_loyalty(added)
	city.add_gold(-money)
	city.add_rice(-rice)
	var extra = SkillRangeBuff.max_val_for_city("赏赐民众效果", city.ID)
	if extra > 0:
		extra = city.add_loyalty(extra)

	var msg = "水之不平，舟其何存？"
	if extra > 0:
		msg += "\n{0}统治度上升{1}+{2}点"
	else:
		msg += "\n{0}统治度上升{1}点"
	msg = msg.format([
		city.get_full_name(), added, extra
	])
	msg += "\n（【{0}】双倍效果".format([ske.skill_name])
	if timesBuff != null:
		msg += "\n（{0}【{1}】{2}倍效果".format([
			ActorHelper.actor(timesBuff.actorId).get_name(),
			timesBuff.skillName, int(timesBuff.effectTagVal),
		])
	SceneManager.play_affiars_animation(
		"Warehouse_AwardPop", "", false,
		msg, actorId, 1
	)
	LoadControl.set_view_model(2999)
	return
