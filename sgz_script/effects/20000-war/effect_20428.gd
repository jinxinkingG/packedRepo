extends "effect_20000.gd"

#智破诱发后的被动效果
#【智破】大战场，诱发技。你的队友被用计时才能发动。你可以发动：你令对方选择一项：1.需额外消耗3点机动力才能继续计策结算；2.本次计策伤害减半。每回合限3次。

func on_trigger_20002()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(actorId) < 0:
		return false
	if se.targetId != ske.actorId:
		return false
	if se.targetId == me.actorId:
		# 不可以对自己发动
		return false
	if not se.damage_soldier():
		# 仅伤兵计可发动
		return false
	if actorId != DataManager.get_env_int("计策.ONCE.智破"):
		return false
	change_scheme_damage_rate(-50)
	return false
