extends "effect_20000.gd"

#诚治锁定效果
#【诚治】大战场，主动技。对方场上的人数至少为3时，你可以令对方选择其场上的1名将领为目标，并消耗你5点机动力发动。目标的机动力+5；之后由你选择下列一项效果适用：1.下次对方回合，目标不能进行攻击宣言；2. 下次对方回合，目标不能用计。每回合限1次。

const ACTIVE_EFFECT_ID = 20533

func on_trigger_20013() -> bool:
	var option = ske.get_war_skill_val_str(ACTIVE_EFFECT_ID, ske.actorId)
	if option == "":
		return false
	ske.set_war_skill_val("", 0, ACTIVE_EFFECT_ID, ske.actorId)
	var wa = DataManager.get_war_actor(ske.actorId)

	if option == "禁止攻击":
		ske.set_war_buff(wa.actorId, "禁兵", 1)
	else:
		option = "禁用计策"
		ske.set_war_buff(wa.actorId, "禁策", 1)
	ske.war_report()

	map.draw_actors()
	var msg = "{0}可恨，动我军心！".format([
		DataManager.get_actor_naughty_title(actorId, wa.actorId),
	])
	wa.attach_free_dialog(msg, 0)
	msg = "{2}受到{0}【{1}】钳制".format([
		actor.get_name(), ske.skill_name, wa.get_name(),
	])
	msg += "\n本回合" + option
	wa.attach_free_dialog(msg, 0, 20000, -2)
	return false
