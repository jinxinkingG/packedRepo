
extends "effect_20000.gd"

#稳进被动效果部分
#【稳进】大战场，主动技。①使用后记录你的机动力为X，再清空。则下回你你恢复机动力时，额外恢复X点，X最大为18，每2回合限1次。②你机动力为0时，受到计策伤害-50%.

const ACTIVE_EFFECT_ID = 20555
const EXTRA_RECOVER_LIMIT = 18

func on_trigger_20002() -> bool:
	if me.action_point != 0:
		return false
	change_scheme_damage_rate(-50)
	return false

func on_trigger_20013() -> bool:
	var ap = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID)
	ap = min(EXTRA_RECOVER_LIMIT, ap)
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	ske.change_actor_ap(actorId, ap)
	ske.war_report()
	return false
