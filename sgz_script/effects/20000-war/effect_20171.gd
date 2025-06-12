extends "effect_20000.gd"

#备策
#【备策】大战场,锁定技。每回合你第一次使用计策后，返还本次消耗的机动力的75%。

const EFFECT_ID = 20171

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	# 这里有意思的是，备策触发 id 是计策的 actionId
	# 也就是说，有人代为发动时，两者都不触发，也说得过去
	if se.fromId != actorId:
		return false
	var ap = int(se.cost * 3 / 4)
	if ap <= 0:
		return false

	ske.cost_war_cd(1)
	ske.change_actor_ap(actorId, ap)
	ske.war_report()

	se.skip_redo = 1
	var msg = "备而无患，来而无妨\n（因【{0}】效果\n（机动力回复{1}".format([
		ske.skill_name, ap
	])
	me.attach_free_dialog(msg, 1)
	return false
