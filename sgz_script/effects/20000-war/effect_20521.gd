extends "effect_20000.gd"

#行歇锁定效果
#【行歇】大战场，主动技。你每移动一步，你的[歇]标记+1，上限20个。你可以发动本技能：每消耗2个[歇]标记，你的体+1。

const EFFECT_ID = 20521
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "歇"

func effect_20521_start() -> void:
	var flags = ske.get_skill_flags(20000, ske.effect_Id, FLAG_NAME)
	var recover = int(flags / 2)
	if recover <= 0:
		var msg = "无 [{0}] 可用".format([FLAG_NAME])
		play_dialog(actorId, msg, 3, 2999)
		return
	recover = ske.change_actor_hp(actorId, recover)
	if recover <= 0:
		var msg = "体力充沛，无须回复".format([FLAG_NAME])
		play_dialog(actorId, msg, 1, 2999)
		return
	var cost = recover * 2
	ske.cost_skill_flags(20000, ske.effect_Id, FLAG_NAME, cost)
	ske.war_report()
	var msg = "消耗 {0} 个 [{1}]\n体力回复 {2} -> {3}".format([
		cost, FLAG_NAME, recover, actor.get_hp(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return
