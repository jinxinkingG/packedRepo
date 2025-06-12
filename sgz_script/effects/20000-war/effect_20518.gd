extends "effect_20000.gd"

#虎啸锁定效果
#【虎啸】大战场，锁定技。你非主将时：①于大战场/小战场/单挑中体力变为0的场合，你可选择“防具”或“道具”栏中的1个禁用，才能发动：你免疫那次死亡/俘虏，体力恢复满值，并直接回营。②你每禁用1个装备栏，攻击所需的机动力减少1点(至少为1)。

func on_trigger_20014() -> bool:
	var setting = DataManager.get_env_dict("战争.攻击消耗")
	var disabled = 0
	for equip in actor.all_equips():
		if equip.type_disabled():
			disabled += 1
	setting["减少"] += disabled
	setting["至少"] = 1
	DataManager.set_env("战争.攻击消耗", setting)
	return false
