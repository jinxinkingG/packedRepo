extends "effect_30000.gd"

#暴名效果实现
#你用（20+武-德）代替智计算战术值。对方持续型战术生效后，本回合结束时，该战术回合数清零

func on_trigger_30006()->bool:
	var sbp = ske.get_battle_skill_property()
	var wisdom = max(1, 20 + actor.get_power() - actor.get_moral())
	sbp.alternative_wisdom_for_tp = wisdom
	ske.apply_battle_skill_property(sbp)
	ske.battle_report()
	return false

func on_trigger_30009()->bool:
	for buff in enemy.get_battle_buffs():
		ske.remove_battle_buff(enemy.actorId, buff)
	ske.battle_report()
	return false
