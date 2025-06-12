extends "effect_20000.gd"

#断肠
#【断肠】大战场，锁定技。敌方五行为木、火的武将，无法使用计策。

func on_trigger_20024()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false

	var key = "战争.计策.允许.{0}".format([ske.actorId])
	if DataManager.get_env_int(key) != 1:
		return false
	match wa.five_phases:
		War_Character.FivePhases_Enum.Wood:
			pass
		War_Character.FivePhases_Enum.Fire:
			pass
		_:
			return false
	var msg = "因{0}【{1}】效果\n不能使用计策".format([me.get_name(), ske.skill_name])
	DataManager.set_env(key, msg)
	return false
