extends "effect_20000.gd"

#吞据被动触发判断
#【吞据】大战场，锁定技。你非主将时，视为拥有<复勇>。你方主将（非君主）死亡/被俘虏/大战场撤退时，你自动接任主将，并获得原主将50%兵力，接受兵力后，不超过自身带兵上限。

func on_trigger_20027()->bool:
	# 战争结束，不生效
	if DataManager.get_env_int("战争.结算进行") > 0:
		return false
	if me.actorId == ske.actorId:
		# 自己不发动
		return false
	if ske.actorId != me.get_main_actor_id():
		# 不是主将不发动
		return false
	var leader = DataManager.get_war_actor(ske.actorId)
	if leader.actor().get_loyalty() == 100:
		# 君主不发动
		return false
	var soldiers = int(leader.get_soldiers() / 2)
	var limit = DataManager.get_actor_max_soldiers(actorId)
	if soldiers > 0:
		ske.change_actor_soldiers(leader.actorId, -soldiers)
		ske.change_actor_soldiers(me.actorId, soldiers, limit)
		ske.war_report()
	# 主将即将完蛋，在此之前，让自己成为主将
	me.war_vstate().main_actorId = me.actorId
	var msg = "{0}虽去，吾今尚在！\n云何以一人废战事？\n（{1}【{2}】成为主将".format([
		DataManager.get_actor_honored_title(ske.actorId, me.actorId),
		me.get_name(), ske.skill_name,
	])
	me.attach_free_dialog(msg, 0)
	return false
