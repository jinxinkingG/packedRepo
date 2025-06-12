extends "effect_20000.gd"

#才瑕效果实现
#【才瑕】大战场，锁定技。你用计结束时，交替执行AB效果，每回合默认从A开始，执行后切换。 A.你的机动力增加用计消耗的50%； B.你的机动力减少用计消耗的50%。

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	var ap = int((se.cost + 1) / 2)
	var flag = ske.get_war_skill_val_int()
	var change = 0
	if flag % 2 == 0:
		change = ske.change_actor_ap(actorId, ap)
	else:
		change = ske.change_actor_ap(actorId, -ap)
	ske.set_war_skill_val(flag + 1, 1)
	if change != 0:
		se.append_result("机动力", ske.skill_name, change, actorId)
	return false
