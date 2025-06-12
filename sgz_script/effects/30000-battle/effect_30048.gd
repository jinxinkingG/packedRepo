extends "effect_30000.gd"

#先制效果实现
#【先制】小战场,锁定技。你的战术持续回合内，对方若使用战术，则你获得对方消耗的战术值

func check_trigger_correct():
	if not DataManager.common_variable.has("白兵.战术消耗"):
		return false
	var cost = int(DataManager.common_variable["白兵.战术消耗"])
	var wa = DataManager.get_war_actor(self.actorId)
	for buff in StaticManager.CONTINUOUS_TACTICS:
		var buff_status = wa.get_buff(buff)
		if buff_status["回合数"] > 0:
			wa.battle_tactic_point += cost
			break
	return false
