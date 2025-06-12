extends "effect_20000.gd"

# 跋涉效果
#【跋涉】大战场，锁定技。你通过移动每消耗1点机动力，则增加1点经验。

func on_trigger_20003() -> bool:
	var cost = DataManager.get_env_dict("移动消耗")
	if not "机" in cost:
		return false
	var ap = Global.intval(cost["机"])
	var daily = ske.get_war_skill_val_int()
	if DataManager.get_env_int("移动") in [-1, 1]:
		daily += ap
		ske.set_war_skill_val(daily, 1)
		ske.change_actor_exp(actorId, ap)
	return false
