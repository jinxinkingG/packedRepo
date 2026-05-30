extends "effect_30000.gd"

#禁酒锁定技
#【禁酒】小战场,锁定技。①你的士兵单位，兵力低于100时，攻击力不减。②若你为高顺：你的士兵单位，兵力大于150时，单次受到士兵的伤害上限为25。

const GAOSHUN_ID = StaticManager.ACTOR_ID_GAOSHUN
const DAMAGE_CAP = 25
const HP_THRESHOLD_LOW = 100
const HP_THRESHOLD_HIGH = 150

# 效果①：士兵兵力<100时攻击力不减
func on_trigger_30014()->bool:
	var bu = get_action_unit()
	if bu == null or bu.leaderId != actorId:
		return false
	if not bu.is_soldier():
		return false
	if bu.get_hp() >= HP_THRESHOLD_LOW:
		return false
	DataManager.set_env("白兵.伤害基准体力", HP_THRESHOLD_LOW)
	return false

# 效果②：高顺专属，士兵兵力>150时单次承伤上限25
func on_trigger_30011()->bool:
	if actorId != GAOSHUN_ID:
		return false
	var unitId = DataManager.get_env_int("白兵伤害.单位")
	var bu = ske.get_battle_unit(unitId)
	if bu == null or bu.leaderId != actorId:
		return false
	if not bu.is_soldier():
		return false
	if bu.get_hp() <= HP_THRESHOLD_HIGH:
		return false
	var fromUnitId = DataManager.get_env_int("白兵伤害.来源")
	var fromUnit = ske.get_battle_unit(fromUnitId)
	if fromUnit == null or fromUnit.leaderId == actorId:
		return false
	if not fromUnit.is_soldier():
		return false
	var damage = DataManager.get_env_float("白兵伤害.伤害")
	DataManager.set_env("白兵伤害.伤害", min(DAMAGE_CAP, damage))
	return false
