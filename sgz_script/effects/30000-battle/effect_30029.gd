extends "effect_30000.gd"

#巨象效果实现
#【巨象】小战场,锁定技。你拥有象兵。象兵：基础减伤倍率0.65，基础伤害倍率2.2，小战场，每轮初始时，象兵hp低于100，则该轮可2动；低于50，该轮3动。

const EFFECT_ID = 30029

func on_trigger_30033()->bool:
	var formationKey = "白兵.阵型优先.{0}".format([me.actorId])
	if get_env_int(formationKey) > 1:
		return false

	var setting = get_env_dict("兵种数量")
	var sorting = get_env_array("分配顺序")
	if setting.has("骑"):
		setting["象"] = setting["骑"]
		setting.erase("骑")
	var loc = sorting.find("骑")
	if loc >= 0:
		sorting[loc] = "象"
	set_env("兵种数量", setting)
	set_env("分配顺序", sorting)
	set_env(formationKey, 1)

	return false
