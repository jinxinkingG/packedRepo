extends "effect_20000.gd"

#机变
#【机变】大战场,锁定技。回合初始，根据你的花色，你本回合内，自动附加以下技能：红桃和方块附加<势威>，黑桃附加<魂智>，梅花附加<智神>

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("势威")
		War_Character.FivePhases_Enum.Fire:
			ret.append("势威")
		War_Character.FivePhases_Enum.Metal:
			ret.append("魂智")
		War_Character.FivePhases_Enum.Water:
			ret.append("智神")
	return ret
