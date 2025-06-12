extends "effect_30000.gd"

#横歇效果
#【横歇】小战场，锁定技。你触发格挡时，你的体力+1。

const HP_RECOVER = 1

func on_trigger_30011() -> bool:
	var bu = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["将"], ["ALL"], true)
	if bu == null:
		return false
	var actorUnit = me.battle_actor_unit()
	if actorUnit == null or actorUnit.disabled:
		return false

	if bu.dic_other_variable.has("被格挡") and bu.dic_other_variable["被格挡"]:
		ske.battle_change_unit_hp(actorUnit, HP_RECOVER)
	return false
