extends "effect_40000.gd"

# 催阵单挑效果实现
#【催阵】小战场，锁定技。仅在白刃战场景下，视为禁用对方的武器栏。

const BATTLE_EFFECT_ID = 30303

func on_trigger_40010() -> bool:
	if ske.get_battle_skill_val_int(BATTLE_EFFECT_ID) <= 0:
		return false
	# TODO 先简单实现吧，未来有冲突再说
	DataManager.clear_actor_disabled_equip_types(30000)
	return false
