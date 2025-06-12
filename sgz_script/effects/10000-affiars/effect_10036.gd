extends "effect_10000.gd"

#解仇效果
#【解仇】内政,主动技。被你方流放/斩首过的武将，被你方搜到时，你将出面调解，令对方愿意加入。

const EFFECT_ID = 10036
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10015()->bool:
	var cmd = DataManager.get_current_search_command()
	if cmd == null:
		return false
	return true

func effect_10036_start():
	var cmd = DataManager.get_current_search_command()
	var msg = "某虽不才，不事无义之主！"
	play_dialog(cmd.foundActorId, msg, 2, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10036_2():
	var cmd = DataManager.get_current_search_command()
	var title = "我主"
	if actor.get_loyalty() == 100:
		title = "孤"
	var msg = "前事实有诸般不得己\n今{1}诚意相招\n望{0}大量，新生不念旧怨".format([
		DataManager.get_actor_honored_title(cmd.foundActorId, actorId), title
	])
	play_dialog(actorId, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_10036_3():
	var cmd = DataManager.get_current_search_command()
	cmd.actorJoin = 0
	cmd.actorCost = 0
	# 以解仇武将计算相性差异
	cmd.distance = actor.personality_distance(cmd.found_actor())
	cmd.decide_loyalty_by_distance()
	cmd.accept_actor()
	var msg = "…… ……\n{0}意诚，某亦感念\n往事不论。愿效犬马之劳！".format([
		DataManager.get_actor_honored_title(actorId, cmd.foundActorId),
	])
	play_dialog(cmd.foundActorId, msg, 2, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_end")
	return

func effect_10036_end():
	skill_end_clear(true)
	FlowManager.add_flow("player_ready")
	return
