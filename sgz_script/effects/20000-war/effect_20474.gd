extends "effect_20000.gd"

#涌谋被动效果部分
#【涌谋】大战场，主动技。选择1名敌将为目标，消耗你20个[备]标记才能发动。直到回合结束前，目标“知”视为-10；若目标被用计，则其“知”在计策结束时恢复。每回合限3次。

const REDUCE_WISDOM = 10

func on_trigger_20012()->bool:
	# 己方用计，解除目标的降智效果
	var se = DataManager.get_current_stratagem_execution()
	var marked = ske.get_war_skill_val_int_array()
	if not se.targetId in marked:
		return false
	marked.erase(se.targetId)
	ske.set_war_skill_val(marked, 99999)
	ske.change_war_wisdom(se.targetId, REDUCE_WISDOM)
	ske.war_report()
	return false

func on_trigger_20016()->bool:
	clear_buff()
	return false

func on_trigger_20027()->bool:
	clear_buff()
	return false

func clear_buff()->void:
	var marked = ske.get_war_skill_val_int_array()
	for targetId in marked:
		ske.change_war_wisdom(targetId, REDUCE_WISDOM)
	ske.set_war_skill_val([], 99999)
	ske.war_report()
	return
