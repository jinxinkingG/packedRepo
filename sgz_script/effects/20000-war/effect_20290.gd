extends "effect_20000.gd"

#犄角，各种事件时更新光环
#【犄角】大战场，锁定技。你与你方主将距离4格以内时，两人所有计算中的武和智选两人较高者参与计算。你或该武将不在大战场时，本效果消失。

func on_trigger_20003()->bool:
	_update_buff()
	return false

func on_trigger_20013()->bool:
	_update_buff()
	return false

func on_trigger_20015()->bool:
	_update_buff()
	return false

func on_trigger_20027()->bool:
	_update_buff(true)
	return false

func on_trigger_20031()->bool:
	_update_buff()
	return false

func _update_buff(justClear:bool=false)->bool:
	if me == null:
		return false
	if me.get_main_actor_id() == me.actorId:
		# 自身是主将，不触发
		return false
	var leader = DataManager.get_war_actor(me.get_main_actor_id())
	if leader == null:
		return false
	if not ske.actorId in [me.actorId, leader.actorId]:
		# 其他武将的行为，忽略
		return false
	me.dic_other_variable.erase("武环")
	me.dic_other_variable.erase("知环")
	leader.dic_other_variable.erase("武环")
	leader.dic_other_variable.erase("知环")
	if justClear:
		return false
	if me.disabled or not me.has_position():
		return false
	if leader.disabled or not leader.has_position():
		return false
	var disv = me.position - leader.position
	if max(abs(disv.x), abs(disv.y)) > 4:
		return false
	var leaderActor = ActorHelper.actor(leader.actorId)
	me.dic_other_variable["武环"] = leaderActor.get_power()
	leader.dic_other_variable["武环"] = actor.get_power()
	me.dic_other_variable["知环"] = leaderActor.get_wisdom()
	leader.dic_other_variable["知环"] = actor.get_wisdom()
	return true
