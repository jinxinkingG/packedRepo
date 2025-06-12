extends "effect_20000.gd"

#截先诱发技
#【截先】大战场，诱发技。你的队友被攻击的场合才能发动。交换那次小战场的攻守方。每回合限一次。

const EFFECT_ID = 20038
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.actorId != bf.get_defender_id():
		# 队友非守方
		return false
	if ske.actorId == ske.skill_actorId:
		# 自己是守方
		return false
	return true

func effect_20038_AI_start():
	var bf = DataManager.get_current_battle_fight()
	if bf.get_terrian() in StaticManager.CITY_BLOCKS_EN:
		back_to_induce_ready()
		return
	goto_step("2")
	return

func effect_20038_start():
	var bf = DataManager.get_current_battle_fight()
	
	map.cursor.hide()
	var msg = "发动【{0}】\n令{1}反守为攻\n可否？".format([
		ske.skill_name, bf.get_defender().get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	map.next_shrink_actors = [me.actorId, bf.attackerId, bf.defenderId]
	return

func effect_20038_2():
	var bf = DataManager.get_current_battle_fight()
	
	ske.cost_war_cd(1)

	var originalDefenderId = bf.get_defender_id()
	var originalAttackedId = bf.get_attacker_id()
	bf.attackerId = originalDefenderId
	bf.defenderId = originalAttackedId
	var msg = "{0}与{1}攻守互换".format([
		bf.get_defender().get_name(), bf.get_attacker().get_name(),
	])
	ske.append_message(msg, -1)
	if bf.get_terrian() in StaticManager.CITY_BLOCKS_EN:
		bf.terrian = "land"
		ske.append_message("战斗改为平原战", -1)
	ske.war_report()

	msg = "{0}骄兵必败\n{1}可攻其不备！\n（{2}".format([
		DataManager.get_actor_naughty_title(bf.defenderId, me.actorId),
		DataManager.get_actor_honored_title(bf.attackerId, me.actorId),
		msg,
	])
	play_dialog(me.actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, bf.attackerId, bf.defenderId]
	return
