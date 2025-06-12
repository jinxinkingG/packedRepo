extends "effect_20000.gd"

#恃功
#【恃功】大战场,锁定技。你用伤兵计策成功时，150%的伤害；失败时，额外扣除该计策所需机动力一半的机动力，不足则全扣。

const DAMAGE_RAISE = 50

func on_trigger_20011()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(actorId) != actorId:
		return false
	change_scheme_damage_rate(DAMAGE_RAISE)
	return false

func on_trigger_20009()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(actorId) != actorId:
		return false
	if se.succeeded > 0:
		return false
	var extraCost = int(se.cost / 2)
	if extraCost <= 0:
		return false
	extraCost = ske.cost_ap(extraCost)
	if extraCost <= 0:
		return false
	var msg = "大言炎炎，额外失去{0}机动力".format([extraCost])
	if me.get_controlNo() < 0:
		msg = "{0}大言炎炎\n额外失去{1}机动力".format([
			me.get_name(), extraCost
		])
	se.append_result(ske.skill_name, msg, extraCost, actorId)
	map.update_ap()
	return false
