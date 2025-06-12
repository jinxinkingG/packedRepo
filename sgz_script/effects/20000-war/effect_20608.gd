extends "effect_20000.gd"

# 密帆效果
#【密帆】大战场，锁定技。若你使用过<密信>，不论成功失败，直到本次战争结束前，你在水地形移动消耗的机动力只需1点。

const MIXIN_EFFECT_ID = 20607

func on_trigger_20007() -> bool:
	var flags = ske.get_war_skill_val_int_array(MIXIN_EFFECT_ID)
	if flags.size() != 2:
		return false
	set_max_move_ap_cost(["河流"], 1)
	return false
