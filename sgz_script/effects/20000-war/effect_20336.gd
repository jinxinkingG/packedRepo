extends "effect_20000.gd"

#纵节锁定效果
#【纵节】大战场，锁定技。每日回复机动力时，你可突破机动力上限，最多回复到你的 [知] 数值。

func on_trigger_20013()->bool:
	var exceededKey = "战争.机动力溢出.{0}".format([actorId])
	var exceeded = DataManager.get_env_int(exceededKey)
	exceeded = min(exceeded, actor.get_wisdom() - me.get_max_action_ap())
	if exceeded > 0:
		ske.change_actor_ap(actorId, exceeded)
	DataManager.unset_env(exceededKey)
	ske.war_report()
	return false
