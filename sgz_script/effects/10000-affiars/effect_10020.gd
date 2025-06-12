extends "effect_10000.gd"

#天子效果
#【天子】内政,锁定技。他势力的易招揽武将，若其“德”＞75，则视为你方势力的易招揽武将

const EFFECT_ID = 10020
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10005()->bool:
	var cmd = DataManager.get_current_search_command()
	if cmd == null:
		return false
	if cmd.result != 10 or cmd.foundActorId < 0:
		return false
	if cmd.found_actor().get_moral() > 75:
		# 尝试追加说服
		var rate:int = int(13.0 * 100 / 15.0)
		if Global.get_rate_result(rate):
			return true
	return false

func effect_10020_start()->void:
	var cmd = DataManager.get_current_search_command()
	var msg = "在下久居山野\n请恕实在不能从命…"
	play_dialog(cmd.foundActorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10020_2()->void:
	var msg = "汉室衰微如此\n先生岂可避世不出？"
	play_dialog(actorId, msg, 3, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_10020_3()->void:
	var cmd = DataManager.get_current_search_command()
	cmd.result = 5
	cmd.actorJoin = 1
	cmd.actorCost = 0
	cmd.accept_actor()
	var msg = "此臣之过…\n当随陛下驱驰"
	cmd.city().attach_free_dialog(msg, cmd.foundActorId, 2)
	skill_end_clear(true)
	FlowManager.add_flow("player_ready")
	return
