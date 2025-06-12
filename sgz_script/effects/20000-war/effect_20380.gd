extends "effect_20000.gd"

#龙魂大战场效果
#【龙魂】单挑，锁定技。你未装备“青龙偃月刀”时，暴击率+20%；否则，你的五行为金、水时，也同时附加<神武>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var actor = ActorHelper.actor(self.actorId)
	if actor.get_weapon().id != StaticManager.WEAPON_ID_YANYUE:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Metal:
			ret.append("神武")
		War_Character.FivePhases_Enum.Water:
			ret.append("神武")
	return ret
