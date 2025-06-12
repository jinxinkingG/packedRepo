extends "effect_20000.gd"

#诡治锁定效果
#【诡治】大战场，主动技。对方场上人数至少为3时，你可以选择对方场上1名武将为目标，并消耗5点机动力发动。下次对方回合，目标机动力-5；之后令对方选择下列一项效果适用: 1.目标不能攻击宣言；2.目标不能用计。每回合限1次。

const ACTIVE_EFFECT_ID = 20527

const LOST_AP = 5

func on_trigger_20013() -> bool:
	var option = ske.get_war_skill_val_str(ACTIVE_EFFECT_ID, ske.actorId)
	if option == "":
		return false
	ske.set_war_skill_val("", 0, ACTIVE_EFFECT_ID, ske.actorId)
	var wa = DataManager.get_war_actor(ske.actorId)
	var lost = ske.change_actor_ap(wa.actorId, -LOST_AP)

	if option == "自选":
		# 偷个懒，目前诡治只能玩家发动，所以 AI 直接选择效果就好
		option = "禁止攻击"
		if actor.get_wisdom() < 85:
			option = "禁用计策"
	if option == "禁止攻击":
		ske.set_war_buff(wa.actorId, "禁兵", 1)
	else:
		option = "禁用计策"
		ske.set_war_buff(wa.actorId, "禁策", 1)
	ske.war_report()

	map.draw_actors()
	var msg = "{0}技止此耳！".format([
		DataManager.get_actor_naughty_title(actorId, wa.actorId),
	])
	wa.attach_free_dialog(msg, 0)
	msg = "{2}受到{0}【{1}】钳制".format([
		actor.get_name(), ske.skill_name, wa.get_name(),
	])
	if lost < 0:
		msg += "\n机动力 {0}".format([lost])
	msg += "\n本回合" + option
	wa.attach_free_dialog(msg, 0, 20000, -2)
	return false
