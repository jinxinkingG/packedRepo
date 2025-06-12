extends "effect_30000.gd"

#暴虐锁定技
#【暴虐】大战场，君主锁定技。你方武将白刃战获胜后，你的兵力回复本次白刃战“敌方兵力损失的10%”。

func on_trigger_30004() -> bool:
	if actor.get_loyalty() != 100:
		return false
	var wa
	if ske.actorId == actorId:
		wa = me
	else:
		wa = DataManager.get_war_actor(ske.actorId)
		if not me.is_teammate(wa):
			return false
	var enemy = wa.get_battle_enemy_war_actor()
	if enemy == null:
		return false
	if bf.loserId != enemy.actorId:
		return false
	var prev = bf.attackerSoldiers
	if enemy.actorId == bf.get_defender_id():
		prev = bf.defenderSoldiers
	var current = enemy.get_soldiers()
	match bf.lostType:
		BattleFight.ResultEnum.ActorDead:
			# 武将死亡，视为士兵全损
			current = 0
		BattleFight.ResultEnum.ActorSurrend:
			# 武将投降，视为士兵全损
			current = 0
	if current >= prev:
		return false
	var x = int((prev - current) / 10)
	if x <= 0:
		return false
	var limit = DataManager.get_actor_max_soldiers(actorId)
	x = ske.change_actor_soldiers(actorId, x, limit)
	if x <= 0:
		return false
	# 虽然是小战场触发，但属于大战场效果，汇报大战场日志
	ske.war_report()
	var msg = "收拢败兵\n尚能战者，令为前驱！\n（【{0}】士兵回复{1}".format([ske.skill_name, x])
	me.attach_free_dialog(msg, 1)
	return false
