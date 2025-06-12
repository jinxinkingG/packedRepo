extends "effect_40000.gd"

#龙魂单挑效果
#【龙魂】单挑，锁定技。你未装备“青龙偃月刀”时，暴击率+20%；否则，你的五行为金、水时，也同时附加<神武>。

func on_trigger_40005()->bool:
	if actor.get_weapon().id == StaticManager.WEAPON_ID_YANYUE:
		return false
	var rate = DataManager.get_env_int("单挑.暴击率")
	DataManager.set_env("单挑.暴击率", rate + 20)
	return false
