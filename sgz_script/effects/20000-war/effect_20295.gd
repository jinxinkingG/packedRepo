extends "effect_20000.gd"

#傲智效果
#【傲智】大战场&小战场，锁定技。若你是本方知最高的武将或之一，你的知+10（最高99）

const WISDOM_BUFF = 10

func on_trigger_20013()->bool:
	var maxWisdom = true
	for targetId in get_teammate_targets(me, 999):
		var teammate = ActorHelper.actor(targetId)
		# 比较原始智力
		if teammate._get_attr_int("知") > actor._get_attr_int("知"):
			maxWisdom = false
			break
	if maxWisdom:
		if ske.get_war_skill_val_int() > 0:
			return false
		ske.set_war_skill_val(1)
		ske.change_war_wisdom(me.actorId, WISDOM_BUFF)
		ske.war_report()
	else:
		if ske.get_war_skill_val_int() <= 0:
			return false
		ske.change_war_wisdom(me.actorId, -WISDOM_BUFF)
		ske.set_war_skill_val(0)
		ske.war_report()
	return false
