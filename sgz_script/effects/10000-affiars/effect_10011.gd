extends "effect_10000.gd"

#荐才效果二及误信，截胡忽悠
#【荐才】内政，锁定技。每年一月、五月。九月，若势力范围内的城池内有在野武将，则自动寻得一位加入本城。他势力的易招揽武将若拒绝加入，则由你出面说服，概率为5*你的等级%
#【误信】内政，转换技·锁定。你视为拥有技能<荐才>。若你当前所在势力不是“初次出仕的势力”（@初势力），且该势力未灭亡，则你永久转为<阴>。

const EFFECT_ID = 10011
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10005()->bool:
	var cmd = DataManager.get_current_search_command()
	if cmd == null:
		return false
	if cmd.result != 10 or cmd.foundActorId < 0:
		return false

	# 尝试追加说服
	var rate = int(2.0 * 100 / 15.0) + 10 + 5 * actor.get_level()
	if not Global.get_rate_result(rate):
		return false

	# 追加说服成功，开始表演
	return true

func effect_10011_start()->void:
	var cmd = DataManager.get_current_search_command()
	var msg = "在下久居山野\n请恕实在不能从命…"
	play_dialog(cmd.foundActorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10011_2()->void:
	var msg = "先生既有大才，岂无大志？\n望以苍生为念，济世安邦"
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_10011_3()->void:
	var cmd = DataManager.get_current_search_command()
	cmd.result = 5
	cmd.actorJoin = 1
	cmd.actorCost = 0
	cmd.accept_actor()
	var msg = "既如此…\n当随主公驱驰"
	cmd.city().attach_free_dialog(msg, cmd.foundActorId, 2)
	skill_end_clear(true)
	FlowManager.add_flow("player_ready")
	return
