extends "effect_20000.gd"

#豹变锁定效果
#【豹变】大战场,锁定技。若你花色为黑色，你视为拥有<神速>；若你花色为红色，你视为拥有<咆哮>。

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("咆哮")
		War_Character.FivePhases_Enum.Fire:
			ret.append("咆哮")
		War_Character.FivePhases_Enum.Water:
			ret.append("神速")
		War_Character.FivePhases_Enum.Metal:
			ret.append("神速")
		War_Character.FivePhases_Enum.Earth:
			ret.append("咆哮")
			ret.append("神速")
	return ret
