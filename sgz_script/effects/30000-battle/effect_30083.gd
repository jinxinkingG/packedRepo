extends "effect_30000.gd"

#身先效果
#【身先】小战场，锁定技。若你是大战场本回合，你方第一个进入白兵战斗的武将，直到本回合结束之前，你获得<箭令>和<振奋>

func on_trigger_30050():
	if ske.get_war_skill_val_int() == 1:
		return false
	var bf = DataManager.get_current_battle_fight()
	var flag = 1
	if me.actorId == bf.get_attacker_id():
		flag = 2
	if me.actorId == bf.get_defender_id():
		flag = 2
	ske.set_war_skill_val(flag, 1)
	if flag < 2:
		return false
	ske.add_war_skill(me.actorId, "箭令", 1)
	ske.add_war_skill(me.actorId, "振奋", 1)
	ske.war_report()
	ske.recorded = 0
	ske.battle_report()
	var msg = "何以为帅？\n临难不顾，披堅執銳！\n（{0}发动【{1}】".format([
		me.get_name(), ske.skill_name,
	])
	me.attach_free_dialog(msg, 0, 30000)
	return false
