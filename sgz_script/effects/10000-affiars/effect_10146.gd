extends "effect_10000.gd"

#母仪主动技
#【母仪】内政，主动技。选择城内一个包含阴、阳面的武将为目标，消耗1枚命令书发动。使目标直到本月结束前，无视条件转为另一面。每3月限1次。

const EFFECT_ID = 10146
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 主动技入口
func effect_10146_start()->void:
	var cityId = get_working_city_id()
	if cityId < 0:
		play_dialog(actorId, "不在城中\n无法发动", 3, 2999)
		return
	var city = clCity.city(cityId)
	var targets = []
	for tid in city.get_actor_ids():
		if tid == actorId:
			continue
		var actor = ActorHelper.actor(tid)
		if not actor.has_side():
			continue
		var current = actor.get_side(true)
		if not current in ["阴", "阳"]:
			continue
		targets.append(tid)
	if targets.empty():
		play_dialog(actorId, "城中无合适的目标\n无法发动【{0}】".format([ske.skill_name]), 3, 2999)
		return
	SceneManager.show_actorlist_army(targets, false, "选择目标", false)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	if not wait_for_choose_actor("player_ready"):
		return
	DataManager.set_env("目标", SceneManager.actorlist.get_select_actor())
	goto_step("selected")
	return

func effect_10146_selected()->void:
	var targetId = DataManager.get_env_int("目标")
	var actor = ActorHelper.actor(targetId)
	SceneManager.hide_all_tool()
	var currentSide = actor.get_side(true)
	var newSide = "阴" if currentSide == "阳" else "阳"
	var msg = "令{0}暂时转为{1}面\n可否？".format([
		actor.get_name(), newSide
	])
	play_dialog(actorId, msg, 1, 2001, true)
	return

func on_view_model_2001()->void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10146_confirmed()->void:
	var targetId = DataManager.get_env_int("目标")
	var actor = ActorHelper.actor(targetId)
	var originalSide = actor.get_side(true)
	var newSide = "阴" if originalSide == "阳" else "阳"
	ske.affair_cd(3)
	# 记录目标和原始面，月末 10099 恢复
	ske.affair_set_skill_val([targetId, originalSide, newSide], 1)
	# 转面
	actor.set_side(newSide)
	var msg = "大丈夫因时而动，有何不可？\n（{0}已转为{1}面\n（直至本月结束".format([
		actor.get_name(), newSide,
	])
	play_dialog(actorId, msg, 1, 2999)
	return
