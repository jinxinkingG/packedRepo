extends "effect_30000.gd"

#决猛小战场效果
#【决猛】小战场，锁定技。白刃战初始，你将机动力转化为护甲值（最多转化15点），你受伤时，优先消耗护甲。白刃战结束时，若你护甲值有剩余，重新转化为你的机动力。

const AC_LIMIT = 15

func on_trigger_30005()->bool:
	if me == null or me.action_point <= 0:
		return false
	var bu = get_leader_unit(me.actorId)
	if bu == null or bu.disabled:
		return false
	var ap = min(me.action_point, AC_LIMIT)
	ske.change_actor_ap(me.actorId, -ap)
	ske.battle_change_unit_armor(bu, ap)
	ske.battle_report()
	return false

func on_trigger_30099()->bool:
	if me == null or me.disabled:
		return false
	var bu = get_leader_unit(me.actorId, true)
	if bu == null:
		return false
	var ac = int(bu.extra_armor)
	if ac <= 0:
		return false
	ac = min(ac, AC_LIMIT)
	ske.change_actor_ap(me.actorId, ac)
	# 发生在大战场，大战场汇报
	ske.war_report()
	return false
