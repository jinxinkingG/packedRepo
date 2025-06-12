extends "effect_20000.gd"

#父魂锁定技 #技能附加
#【父魂】大战场&小战场,锁定技。根据你的花色，自动附加技能：红桃和方块附加<神武>，黑桃和梅花附加<咆哮>

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("神武")
		War_Character.FivePhases_Enum.Fire:
			ret.append("神武")
		War_Character.FivePhases_Enum.Metal:
			ret.append("咆哮")
		War_Character.FivePhases_Enum.Water:
			ret.append("咆哮")
		War_Character.FivePhases_Enum.Earth:
			ret.append("神武")
			ret.append("咆哮")
	return ret
