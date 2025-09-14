extends "effect_30000.gd"

# 战决效果
#【战决】小战场，锁定技。你每使用一次战术，你的护甲+5。每场白刃战，限触发3次。

const BUFF_ARMOR = 5
const TIMES_LIMIT = 3

func on_trigger_30008() -> bool:
	var buff = DataManager.get_env_str("值")
	if not buff in StaticManager.CONTINUOUS_TACTICS:
		return false
	var actorUnit = me.battle_actor_unit()
	if actorUnit == null:
		return false
	var changed = ske.battle_change_unit_armor(actorUnit, BUFF_ARMOR)
	if not ske.battle_cost_limited_times(TIMES_LIMIT):
		return false
	ske.battle_report()

	var status = "{0} 甲+{1}".format([
		ske.skill_name, changed
	])
	actorUnit.add_status_effect(status)
	return false
