extends "effect_20000.gd"

#度势锁定技
#【度势】大战场,锁定技。你的机动力为 0 时，恢复等同于你点数的机动力，之后刷新你点数。

func check_trigger_correct()->bool:
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled or not me.has_position():
		return false
	if me.action_point > 0:
		return false
	if me.poker_point == 0:
		return false

	me.action_point = me.poker_point
	me.refresh_poker_random()
	
	var d = War_Character.DialogInfo.new()
	d.text = "审时度势，寻机而动\n（{0}机动力恢复{1}".format([
		ActorHelper.actor(self.actorId).get_name(), me.action_point
	])
	d.actorId = self.actorId
	me.add_dialog_info(d)
	return false
