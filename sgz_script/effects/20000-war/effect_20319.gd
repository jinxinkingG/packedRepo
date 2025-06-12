extends "effect_20000.gd"

#穷追锁定效果
#【穷追】大战场，锁定技。每当对方武将大战场撤退时，直到本场战争结束前，你的机动力上限+5。最多触发5次。

const AP_LIMIT_TIMES = 5
const AP_LIMIT_GAIN = 5

func on_trigger_20027()->bool:
	if get_env_str("战争.DISABLE.TYPE") != "撤退":
		return false

	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	if wa.get_main_actor_id() == wa.actorId:
		# 撤退的是主将，就不发动了
		return false

	if not ske.cost_war_limited_times(AP_LIMIT_TIMES, 99999):
		return false
	if not me.dic_other_variable.has("额外机上限"):
		me.dic_other_variable["额外机上限"] = 0
	me.dic_other_variable["额外机上限"] += AP_LIMIT_GAIN

	var d = War_Character.DialogInfo.new()
	d.actorId = me.actorId
	d.text = "{0}丧胆败逃\n吾等当奋勇，扫灭穷寇！\n（{1}机动力上限增加{2}".format([
		DataManager.get_actor_naughty_title(ske.actorId, me.actorId),
		me.get_name(), AP_LIMIT_GAIN,
	])
	d.mood = 0
	me.add_dialog_info(d)
	return false
