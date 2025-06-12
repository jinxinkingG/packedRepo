extends "effect_20000.gd"

#旋伏锁定技 #交换位置
#【旋伏】大战场，锁定技。你在非城地形时，对方非城地形的武将，其移动停止后，若与你相邻，则强制交换双方位置，且对方兵力-100。

func on_trigger_20003()->bool:
	if DataManager.get_env_int("移动") != 0:
		return false
	if DataManager.get_env_int("结束移动") != 1:
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled or not wa.has_position():
		return false
	var terrian = map.get_blockCN_by_position(wa.position)
	if terrian in StaticManager.CITY_BLOCKS_CN:
		return false
	if Global.get_distance(me.position, wa.position) != 1:
		return false
	ske.swap_war_actor_positions(actorId, wa.actorId)
	var reduced = ske.change_actor_soldiers(wa.actorId, -100)
	var msg = "{0}如此莽撞\n伏兵尽出，袭其后军！\n（{1}与{2}互换位置"
	if abs(reduced) > 0:
		msg += "\n（{1}损兵{3}"
	msg = msg.format([
		DataManager.get_actor_naughty_title(wa.actorId, actorId),
		wa.get_name(), me.get_name(), abs(reduced)
	])
	me.attach_free_dialog(msg, 0)
	ske.war_report()
	return false
