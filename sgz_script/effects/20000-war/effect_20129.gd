extends "effect_20000.gd"

#三栖效果实现
#【三栖】大战场,主动技。你可以消耗1点机动力，将你的军种按改为“山、水、平”任意军种。每回合限3次。

const TYPES = ["山", "水", "平"]
const TIMES_LIMIT = 3
const COST_AP = 1

func effect_20129_start()->void:
	if not assert_action_point(actorId, COST_AP):
		return
	if ske.get_war_limited_times() >= TIMES_LIMIT:
		var msg = "每日军种变更不能超过三次"
		play_dialog(actorId, msg, 3, 2999)
		return

	var types = TYPES.duplicate()
	types.erase(actor.get_troops_type())
	types = types.slice(0, 1)
	var msg = "军种改为？"
	SceneManager.show_yn_dialog(msg, actorId, 2, types)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	var types = TYPES.duplicate()
	types.erase(actor.get_troops_type())
	types = types.slice(0, 1)
	var option = wait_for_skill_option()
	if option >= 0 and option < types.size():
		DataManager.set_env("目标", types[option])
		goto_step("2")
	return

func effect_20129_2():
	var type = DataManager.get_env_str("目标")
	if not type in TYPES:
		play_dialog(actorId, "不可", 3, 2999)
		return

	ske.cost_ap(COST_AP, true)
	actor.set_troops_type(type)
	var msg = "<y{0}>将军种改为<g{1}>".format([
		actor.get_name(), actor.get_troops_type(),
	])
	ske.append_message(msg)
	ske.cost_war_limited_times(TIMES_LIMIT)
	ske.war_report()

	msg = "高山大川，无往不利！\n（已变更为{0}军".format([
		actor.get_troops_type()
	])
	play_dialog(actorId, msg, 1, 2999)
	return
