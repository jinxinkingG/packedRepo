extends "effect_20000.gd"

#纵节锁定效果
#【纵节】大战场，锁定技。每回合你恢复机动力时，没有机动力上限的限制。

func on_trigger_20013()->bool:
	var exceededKey = "战争.机动力溢出.{0}".format([self.actorId])
	var exceeded = get_env_int(exceededKey)
	if exceeded > 0:
		me.action_point += exceeded
	unset_env(exceededKey)
	return false
