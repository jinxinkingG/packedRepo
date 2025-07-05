extends "effect_20000.gd"

#顾局效果实现
#【顾局】大战场,主将锁定技。你方其他武将，若其知＜90，则其使用计策时，计算命中和伤害时，知视为90。

const WISDOM = 90

func on_trigger_20017()->bool:
	wisdom_buff()
	return false

func on_trigger_20029()->bool:
	wisdom_buff()
	return false

func wisdom_buff()->bool:
	if ske.actorId == me.actorId:
		# 自己
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	var fromActor = ActorHelper.actor(ske.actorId)
	var diff = WISDOM - fromActor.get_wisdom()
	if diff <= 0:
		return false
	change_scheme_chance(me.actorId, ske.skill_name, diff)
	return false
