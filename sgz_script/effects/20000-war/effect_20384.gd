extends "effect_20000.gd"

#旋截诱发技 #位移
#【旋截】大战场，诱发技。敌将白刃失败，后退1格时，若其退之前的位置没有武将，你可消耗5点机动力发动。将敌将赶回退之前的位置，你位移至敌将退之后地点。每回合限2次。

const EFFECT_ID = 20384
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20384_AI_start():
	goto_step("2")
	return

func effect_20384_start():
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var loser = bf.get_loser()
	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否".format([
		COST_AP, loser.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	map.next_shrink_actors = [me.actorId, loser.actorId]
	return

func effect_20384_2():
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	var loser = bf.get_loser()

	var original = get_env_dict("战争.战败位置")
	if original.empty():
		return false
	var originalPos = Vector2(int(original["x"]), int(original["y"]))
	ske.change_war_actor_position(me.actorId, loser.position)
	ske.change_war_actor_position(loser.actorId, originalPos)
	ske.cost_war_limited_times(2)
	ske.war_report()

	var msg = "{0}！\n归路已断，还不束手！".format([
		DataManager.get_actor_naughty_title(loser.actorId, me.actorId)
	])
	
	play_dialog(me.actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, loser.actorId]
	return

func effect_20384_3():
	map.next_shrink_actors = []
	skill_end_clear()
	return

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if not me.has_position():
		return false
	var loser = bf.get_loser()
	if loser == null or loser.disabled:
		return false
	if ske.actorId != loser.actorId:
		return false
	var original = get_env_dict("战争.战败位置")
	if original.empty():
		return false
	var originalPos = Vector2(int(original["x"]), int(original["y"]))
	if originalPos == loser.position:
		return false
	if me.get_controlNo() < 0:
		var terrian = map.get_blockCN_by_position(me.position)
		if terrian in ["太守府", "城门"]:
			return false
	var disv = me.position - loser.position
	if max(abs(disv.x), abs(disv.y)) > 6:
		return false
	if me.action_point < COST_AP:
		return false
	return true
