extends "effect_20000.gd"

#洛神效果
#【洛神】大战场，锁定技。准备阶段，你方全体五行为金、水的武将，机动力增加等同于其自身点数的值。

func check_trigger_correct():
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	match wa.five_phases:
		War_Character.FivePhases_Enum.Metal:
			pass
		War_Character.FivePhases_Enum.Water:
			pass
		_:
			return false
	ske.change_actor_ap(wa.actorId, wa.poker_point)
	ske.war_report()
	return false
