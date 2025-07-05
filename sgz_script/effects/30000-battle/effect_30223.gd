extends "effect_30000.gd"

#收降效果实现
#【收降】小战场，锁定技。对方武将被你的士兵击杀/俘虏/逼迫投降后，你获得该对方武将残存（包括离场）的士兵。你以此法接收降兵，上限2500，超过部分返回后备兵。

func on_trigger_30098()->bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null or loser.actorId == actorId:
		return false
	match bf.lostType:
		BattleFight.ResultEnum.ActorDead:
			pass
		BattleFight.ResultEnum.ActorSurrend:
			pass
		_:
			return false
	# 对方战败或投降，归拢其士兵
	var remaining = int(bf.get_battle_sodiers(loser.actorId, true, false))
	for bu in DataManager.battle_units:
		if bu == null or bu.leaderId != loser.actorId:
			continue
		if bu.get_unit_type() in ["将", "城门"]:
			continue
		bu.set_hp(0, true)
	if remaining <= 0:
		return false

	loser.actor().set_soldiers(remaining)
	ske.sub_actor_soldiers(loser.actorId, remaining)
	var recovered = ske.add_actor_soldiers(actorId, remaining, 2500)
	var msgs = []
	if recovered > 0:
		# 加入一个不可见的新战场单位，否则是白加
		# 因为之后还会根据战场剩余士兵数重新计算兵力
		var bu = Battle_Unit.new(actorId)
		bu.unitId = DataManager.battle_units.size()
		bu.direction = 1
		bu.Type = "步（收降）"
		bu._private_hp = recovered
		bu.disabled = false
		bu.unit_position = Vector2(-9, -9)
		DataManager.battle_units.append(bu)
		var msg = "获得兵力{0}".format([recovered])
		msgs.append(msg)
	remaining -= recovered
	if remaining > 0:
		# 仍有富余，放预备兵
		var wf = DataManager.get_current_war_fight()
		var cityId = wf.target_city().ID
		if me.side() == "进攻方":
			cityId = me.war_vstate().from_cityId
		remaining = ske.change_city_property(cityId, "后备兵", remaining)
		if remaining > 0:
			var msg = "{0}兵员补充到{1}后备".format([remaining, clCity.city(cityId).get_full_name()])
			msgs.append(msg)
	if not msgs.empty():
		msgs.insert(0, "发动【{0}】".format([ske.skill_name]))
		me.attach_free_dialog("\n".join(msgs), 1)
	ske.war_report()
	return false
