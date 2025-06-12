extends "effect_20000.gd"

#上将效果
#【上将】大战场&小战场，锁定技。若你是本方武力最高的武将或之一，你的武力+10（大战场面板最高99，小战场可以突破99）

const POWER_BUFF = 10

func on_trigger_20013()->bool:
	return check_buff()

func on_trigger_20031()->bool:
	return check_buff()

func check_buff()->bool:
	var maxPower = true
	for targetId in get_teammate_targets(me, 999):
		var teammate = ActorHelper.actor(targetId)
		# 比较原始武力
		if teammate._get_attr_int("武") > actor._get_attr_int("武"):
			maxPower = false
			break
	if maxPower:
		if ske.get_war_skill_val_int() > 0:
			return false
		ske.set_war_skill_val(1)
		ske.change_war_power(me.actorId, POWER_BUFF)
		ske.war_report()
	else:
		if ske.get_war_skill_val_int() <= 0:
			return false
		ske.change_war_power(me.actorId, -POWER_BUFF)
		ske.set_war_skill_val(0)
		ske.war_report()
	return false
