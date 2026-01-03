extends "effect_30000.gd"

#德化锁定技
#【德化】大战场，锁定技。你方为战争攻方时，对方武将白刃战每轮结束时，其兵力不高于40的士兵单位，倒戈为我方。

const HP_LIMIT = 40

func on_trigger_30059() -> bool:
	var teammateId = -1
	if ske.actorId == bf.get_attacker_id():
		teammateId = bf.get_defender_id()
	elif ske.actorId == bf.get_defender_id():
		teammateId = bf.get_attacker_id()
	else:
		return false

	var teammate = DataManager.get_war_actor(teammateId)
	if not me.is_teammate(teammate):
		return false

	var cnt = 0
	for bu in bf.battle_units(ske.actorId):
		if not bu.is_soldier():
			continue
		if bu.get_hp() > HP_LIMIT:
			continue
		bu.leaderId = teammateId
		bu.add_status_effect("倒戈")
		bu.requires_update = true
		cnt += 1
	if cnt <= 0:
		return false
	ske.append_message("因<y{0}>【{1}】，<r{2}>单位倒戈".format([
		actor.get_name(),ske.skill_name, cnt
	]))
	ske.battle_report()
	return false
