extends "effect_10000.gd"

# 征西效果
#【征西】内政，锁定技。你带队攻下西面城池后，你方势力命令书+1。

func on_trigger_10024() -> bool:
	var wf = DataManager.get_current_war_fight()
	if wf.attackerWV == null:
		return false
	var from = wf.from_city()
	var target = wf.target_city()
	if wf.attackerWV.vstateId != target.get_vstate_id():
		return false
	if target.get_location().x >= from.get_location().x:
		return false
	if target.get_leader_id() != actorId:
		return false
	DataManager.orderbook += 1
	var msg = "何待来日？只争朝夕！\n（【{0}】命令书 +1".format([ske.skill_name])
	target.attach_free_dialog(msg, actorId, 1, [from.ID, target.ID])
	return false
