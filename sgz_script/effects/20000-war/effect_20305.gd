extends "effect_20000.gd"

#枭姬效果
#【枭姬】大战场，锁定技。每回合你自动附加一次性技能<飞羽>。你的五行为木、火时，附加<游弓>；你的五行为金、水时，附加<暴弓>。

const FEIYU_EFFECT_ID = 30175

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	match me.five_phases:
		War_Character.FivePhases_Enum.Wood:
			ret.append("游弓")
		War_Character.FivePhases_Enum.Fire:
			ret.append("游弓")
		War_Character.FivePhases_Enum.Metal:
			ret.append("暴弓")
		War_Character.FivePhases_Enum.Water:
			ret.append("暴弓")
	return ret

func on_trigger_20013() -> bool:
	ske.add_war_skill(actorId, "飞羽", 1, true)
	return false
