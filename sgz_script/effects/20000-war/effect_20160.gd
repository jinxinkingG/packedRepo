extends "effect_20000.gd"

#血符效果
#【血符】大战场,锁定技。每回合初始，你发动黄巾秘术，使你的体力+5，最高99。

func on_trigger_20013():
	var maxHP = actor.get_max_hp()
	var newHP = min(99, int(actor.get_hp()) + 5)
	# 调整体上限
	if newHP > maxHP:
		ske.change_actor_max_hp(actorId, newHP - maxHP)
	if ske.change_actor_hp(actorId, 5) > 0:
		ske.war_report()
	return false
