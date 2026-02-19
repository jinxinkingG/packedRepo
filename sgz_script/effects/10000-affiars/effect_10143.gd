extends "effect_10000.gd"

# 宽纳效果
#【宽纳】内政，君主锁定技。①你方击杀对方君主时，改为令其投降。②加入你方的武将，忠诚度至少为40。

func on_trigger_10024() -> bool:
	var wf = DataManager.get_current_war_fight()
	if wf.attackerWV == null or wf.defenderWV == null:
		return false
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var vstateId = city.get_vstate_id()
	var targetVstateId = -1
	if wf.attackerWV.vstateId == vstateId:
		# 我是攻方
		targetVstateId = wf.defenderWV.vstateId
	elif wf.defenderWV.vstateId == vstateId:
		targetVstateId = wf.attackerWV.vstateId
	if targetVstateId < 0:
		return false
	var targetActor = clVState.vstate(targetVstateId).get_lord()	
	if not targetActor.is_status_dead():
		return false
	# 令其加入
	clCity.move_out(targetActor.actorId)
	targetActor.set_loyalty(targetActor.surrend_loyalty(vstateId))
	targetActor.set_status_officed(vstateId)
	city.add_actor(targetActor.actorId)
	var msg = "存亡有分，非{0}之罪\n孤胸怀天下，岂有不容之理？\n（{1}加入{2}军".format([
		DataManager.get_actor_honored_title(targetActor.actorId, actorId),
		targetActor.get_name(), actor.get_name(),
	])
	city.attach_free_dialog(msg, actorId, 1)
	return false
