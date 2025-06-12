extends "effect_20000.gd"

#赶尽锁定技
#【赶尽】大战场，锁定技。你方回合内，你「攻击宣言选定的敌将」与「实际交战的敌将」相同的场合：若那次白刃战你获得胜利，你执行1次机动力恢复。每3回合限1次

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.get_attacker_id() != actorId:
		return false
	if bf.targetId != bf.get_defender_id():
		return false
	if bf.loserId != bf.targetId:
		return false
	var current = me.action_point
	me.action_point = 0
	me.recharge_action_point()
	var recharged = me.action_point
	me.action_point = current
	ske.change_actor_ap(actorId, recharged)
	ske.cost_war_cd(3)
	var msg = "还有谁！一个不留！\n（{0}触发【{1}】\n机动力回复{2}".format([
		actor.get_name(), ske.skill_name, recharged
	])
	me.attach_free_dialog(msg, 0)
	ske.war_report()
	return false
