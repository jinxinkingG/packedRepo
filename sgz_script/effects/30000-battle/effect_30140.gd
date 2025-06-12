extends "effect_30000.gd"

#虚晃效果
#【虚晃】小战场,锁定技。你触发格挡时，体力+2。使用斧类武器时，你的格挡几率额外+10%。

const HP_RECOVER = 2
const BUFF = {
	"格挡率": 10,
	"BUFF": 1,
}

func on_trigger_30005() -> bool:
	var bu = me.battle_actor_unit()
	if bu == null or bu.disabled:
		return false
	if "斧" in bu.get_unit_equip():
		ske.battle_buff_unit(bu, BUFF)
	return false

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
