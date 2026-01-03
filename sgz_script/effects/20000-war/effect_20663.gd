extends "effect_20000.gd"

# 体弱效果
#【体弱】大战场，锁定技。①你的体力大于1时，每过一日，你的体力-1。②你获得的团队经验+15%。

func on_trigger_20013() -> bool:
	if actor.get_hp() > 1:
		ske.change_actor_hp(actorId, -1)
	var hp = int(actor.get_hp())
	if hp % 10 == 9:
		var msg = "敌军尚未退耶？\n实难久持 ……\n（因【{1}】体力持续降低\n（现为 {2}".format([
			actor.get_short_name(), ske.skill_name, hp,
		])
		me.attach_free_dialog(msg, 3)
	ske.war_report()
	return false
