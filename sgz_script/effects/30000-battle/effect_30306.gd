extends "effect_30000.gd"

# 双矢锁定技
#【双矢】小战场，锁定技。你对距离2-3的单位射箭时，伤害 +70%。

const RANGE_LIMIT = 3
const ENHANCEMENT = {
	"双矢": RANGE_LIMIT,
}

func on_trigger_30021() -> bool:
	var bu = ske.battle_is_unit_hit_by(["将"], ["ALL"], ["射箭"])
	if bu == null:
		return false

	var targetUnitId = DataManager.get_env_int("白兵伤害.单位")
	var targetUnit = get_battle_unit(targetUnitId)
	if targetUnit == null or targetUnit.disabled:
		return false
	var offset = bu.unit_position - targetUnit.unit_position
	if abs(offset.x) + abs(offset.y) > RANGE_LIMIT:
		# 必须在范围内
		return false

	var damage = DataManager.get_env_float("白兵伤害.伤害")
	DataManager.set_env("白兵伤害.伤害", damage * 1.7)
	return false

func on_trigger_30024() -> bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"])
	return false
