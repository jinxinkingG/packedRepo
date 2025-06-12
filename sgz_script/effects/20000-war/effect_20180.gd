extends "effect_20000.gd"

#休整效果实现
#【休整】大战场,锁定技。回合初始，你的体力＜上限时，体力+8，机动力恢复值-1

const HP_RECOVER = 8
const COST_AP = 1

func on_trigger_20013()->bool:
	if actor.get_hp() >= actor.get_max_hp():
		return false
	if me.action_point < COST_AP:
		return false
	ske.change_actor_hp(actorId, HP_RECOVER)
	ske.cost_ap(COST_AP)
	ske.war_report()
	return false
