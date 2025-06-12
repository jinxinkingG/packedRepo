extends "effect_20000.gd"

#悲歌
#【悲歌】大战场,锁定技。敌方花色为金、水的武将，主动技能禁用。

func on_trigger_20023()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false

	match wa.five_phases:
		War_Character.FivePhases_Enum.Metal:
			pass
		War_Character.FivePhases_Enum.Water:
			pass
		_:
			return false
	var me = ActorHelper.actor(ske.skill_actorId)
	var msg = "因{0}【{1}】效果\n不能发动主动技".format([
		me.get_name(), ske.skill_name
	])
	var key = "战争.主动技.允许.{0}".format([ske.actorId])
	DataManager.set_env(key, msg)
	return false
