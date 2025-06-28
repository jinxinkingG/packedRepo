extends "effect_20000.gd"

#穷追锁定效果
#【穷追】大战场，锁定技。每当对方武将大战场撤退时，直到本场战争结束前，你的机动力上限+5。最多触发5次。

const AP_LIMIT_TIMES = 5
const AP_LIMIT_GAIN = 5

func on_trigger_20027()->bool:
	if DataManager.get_env_str("战争.DISABLE.TYPE") != "撤退":
		return false

	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	if wa.get_main_actor_id() == wa.actorId:
		# 撤退的是主将，就不发动了
		return false

	var times = ske.get_war_skill_val_int()
	times += 1
	ske.set_war_skill_val(times)
	if times > AP_LIMIT_TIMES:
		return false
	ske.set_actor_extra_ap_limit(actorId, AP_LIMIT_GAIN * times)

	var msg = "{0}丧胆败逃\n吾等当奋勇，扫灭穷寇！\n（{1}机动力上限增加{2}".format([
		DataManager.get_actor_naughty_title(ske.actorId, actorId),
		me.get_name(), AP_LIMIT_GAIN,
	])
	me.attach_free_dialog(msg, 0)
	return false
