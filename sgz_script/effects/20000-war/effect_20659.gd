extends "effect_20000.gd"

# 威抚效果
#【威抚】大战场，锁定技。你为守方的场合。战争开始时，你的兵力+500（上限2500）；战争结束时，你的兵力-500。

const SOLDIERS = 500

func on_trigger_20019() -> bool:
	if wf.date > 1:
		return false
	var soldiers = ske.get_war_skill_val_int()
	if soldiers > 0:
		return false
	soldiers = ske.add_war_tmp_soldier(actorId, SOLDIERS, 2500)
	ske.set_war_skill_val(soldiers)
	if soldiers > 0:
		var msg = "贼至矣，随我共保{0}\n（【{1}】效果\n（{2}士民投入{3}部".format([
			wf.target_city().get_full_name(), ske.skill_name,
			soldiers, actor.get_name(),
		])
		me.attach_free_dialog(msg, 2)
	ske.war_report()
	return false
