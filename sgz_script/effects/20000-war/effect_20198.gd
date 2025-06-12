extends "effect_20000.gd"

#旋风锁定技
#【旋风】大战场,锁定技。你花点为红色时，发起战斗宣言只需消耗1点机动力；你花点黑色时，可以对距离2以内的对方武将发起战斗宣言。

func check_trigger_correct() -> bool:
	var me = DataManager.get_war_actor(self.actorId)
	if me == null or me.disabled:
		return false
	match self.triggerId:
		20014:
			if not DataManager.common_variable.has("战争.攻击消耗"):
				return false
			match me.five_phases:
				War_Character.FivePhases_Enum.Wood:
					DataManager.common_variable["战争.攻击消耗"]["固定"] = 1
				War_Character.FivePhases_Enum.Fire:
					DataManager.common_variable["战争.攻击消耗"]["固定"] = 1
		20030:
			if not DataManager.common_variable.has("战争.攻击距离"):
				return false
			match me.five_phases:
				War_Character.FivePhases_Enum.Metal:
					DataManager.common_variable["战争.攻击距离"] = 2
				War_Character.FivePhases_Enum.Water:
					DataManager.common_variable["战争.攻击距离"] = 2
	return false
