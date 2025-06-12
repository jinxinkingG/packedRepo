extends "effect_30000.gd"

#孤勇技能实现
#【孤勇】小战场,锁定技。每回合初始，若你兵力＜1000，则你的士气+1。

func on_trigger_30009():
	var bf = DataManager.get_current_battle_fight()
	var soldiers = bf.get_battle_sodiers(me.actorId)
	if soldiers >= 1000:
		return false

	ske.battle_change_morale(1)
	ske.battle_report()

	return false
