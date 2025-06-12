extends "effect_30000.gd"

#伏击锁定技
#【伏击】小战场,锁定技。在山地形或者林地形时，白兵初始，你获得4回合“咒缚”战术，且对方前4回合士兵“包围、后退、待机”随机行动。

func on_trigger_30005()->bool:
	var bf = DataManager.get_current_battle_fight()
	ske.set_war_buff(actorId, "咒缚", 4)
	ske.set_war_buff(enemy.actorId, "混乱", 4)
	ske.battle_report()

	var memo = "处险境而不为备\n全军奇袭！"
	if me.actorId == bf.get_defender_id():
		memo = "蹈死地而不自知\n本将等候多时了！"
	var msg = "{0}{2}\n（{1}被咒缚，全军混乱".format([
		DataManager.get_actor_naughty_title(enemy.actorId, actorId),
		enemy.get_name(), memo,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return true
