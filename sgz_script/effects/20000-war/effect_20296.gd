extends "effect_20000.gd"

#耐马效果
#【耐马】大战场，锁定技。你的马力+x，x＝你的等级×8

const HORSE_POWER_BASE = 8

func check_trigger_correct():
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var actor = ActorHelper.actor(self.actorId)
	me.dic_other_variable["额外马力"] = actor.get_level() * HORSE_POWER_BASE
	return false
