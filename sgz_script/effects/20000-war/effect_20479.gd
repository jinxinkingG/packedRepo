extends "effect_20000.gd"

#奋机锁定技
#【奋机】大战场，锁定技。你机动力为0的场合，你可无消耗攻击敌将，此方式的攻击每回合最多进行2次。

func on_trigger_20014()->bool:
	var dic = DataManager.get_env_dict("战争.攻击消耗")
	if dic.empty():
		return false
	if me.action_point > 0:
		return false
	dic["固定"] = 0
	DataManager.set_env("战争.攻击消耗", dic)
	return false

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != actorId:
		return false
	if bf.ap != 0:
		return false
	ske.cost_war_limited_times(2)
	return false
