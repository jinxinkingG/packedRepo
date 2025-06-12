extends "effect_10000.gd"

# 揣疑效果
#【揣疑】内政，锁定技。非君主时，你每次移动至其他城，增加1个“疑”标记(至多24个)。每拥有1个“疑”，你的兵力上限+25，但忠诚度上限-1。

const FLAG_NAME = "疑"

func on_trigger_10012() -> bool:
	if DataManager.get_env_str("内政.命令") != "移动":
		return false
	if actor.get_loyalty() == 100:
		return false
	ske.add_skill_flags(10000, ske.effect_Id, FLAG_NAME, 1, 24)
	var flags = ske.get_skill_flags(10000, ske.effect_Id, FLAG_NAME)
	if flags > 0:
		actor._set_attr("额外忠上限", -flags)
	return false
