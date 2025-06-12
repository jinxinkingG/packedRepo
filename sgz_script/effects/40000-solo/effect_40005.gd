extends "effect_40000.gd"

#狮血效果
#【狮血】防具「兽带狮盔」附加。
# 单挑中，你的体力不足以承受对方伤害时，你可以完全格挡本次伤害，同一场战争累积触发2次后，直到战争结束前，禁用你的防具栏。

const BROKEN_ID = 10
const TIMES_LIMIT = 2

func on_trigger_40003()->bool:
	var damage = DataManager.get_env_int("单挑.伤害数值")
	var times = ske.get_war_skill_val_int()
	if times >= TIMES_LIMIT:
		return false
	if actor.get_hp() <= damage:
		times += 1
		ske.set_war_skill_val(times)
		var msg = "{0}抵挡{1}点致命伤害"
		if times >= TIMES_LIMIT:
			msg += "，{0}已破损！"
		msg = msg.format([
			actor.get_suit().name(), damage
		])
		if times >= TIMES_LIMIT:
			actor.set_equip(clEquip.equip(BROKEN_ID, "防具"))
		DataManager.set_env("单挑.伤害数值", 0)
		DataManager.set_env("对白", msg)
	return false
