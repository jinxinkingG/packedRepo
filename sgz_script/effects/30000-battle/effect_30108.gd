extends "effect_30000.gd"

#怒剑效果
#【怒剑】小战场,锁定技。你装备剑类武器时，攻击距离默认1-2，你每杀死一个敌方单位，你的体力+2

const REQUIRED_WEAPON_TYPE = "剑"
const HP_RECOVER = 2
const ENHANCEMENT = {
	"近战距离": 2,
	"BUFF": 1,
}

func on_trigger_30023()->bool:
	var bu = me.battle_actor_unit()
	if bu == null or not REQUIRED_WEAPON_TYPE in bu.get_unit_equip():
		return false

	bu = ske.battle_is_unit_hit_by(["将"], UNIT_TYPE_SOLDIERS, ["ALL"])
	if bu == null:
		return false

	var hurtId = DataManager.get_env_int("白兵.受伤单位")
	var hurt = get_battle_unit(hurtId)
	if hurt == null or not hurt.disabled:
		# 不满足攻击判定，或未被击杀，均不触发
		return false

	ske.battle_change_unit_hp(bu, HP_RECOVER)
	return false

func on_trigger_30024()->bool:
	ske.battle_enhance_current_unit(ENHANCEMENT, ["将"], REQUIRED_WEAPON_TYPE)
	return false
