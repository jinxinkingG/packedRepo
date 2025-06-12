extends "effect_30000.gd"

#豪猛锁定技
#【豪猛】小战场，锁定技。在你的持续性战术回合期间，你造成125%的伤害。

const EFFECT_ID = 30169

func check_trigger_correct():
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	var unit = me.battle_actor_unit()
	if unit == null or unit.disabled:
		return false
	if unit.dic_combat.has("额外伤害") \
		and get_skill_triggered_times(self.actorId, EFFECT_ID) > 0:
		clear_skill_triggered_times(self.actorId, EFFECT_ID)
		unit.dic_combat["额外伤害"] -= 0.25
		unit.mark_buffed(0)
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] > 0:
			inc_skill_triggered_times(self.actorId, EFFECT_ID, 99999)
			if not unit.dic_combat.has("额外伤害"):
				unit.dic_combat["额外伤害"] = 0
			unit.dic_combat["额外伤害"] += 0.25
			unit.mark_buffed()
			break
	return false
