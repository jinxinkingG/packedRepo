extends "effect_10000.gd"

# 逆乱效果
#【逆乱】内政，锁定技。你所在势力每月第1次出征，且你在出征队伍中时，不消耗命令书。

func on_trigger_10022() -> bool:
	var wf = DataManager.get_current_war_fight()
	var fromCity = wf.from_city()
	if DataManager.get_war_times(fromCity.get_vstate_id()) > 0:
		return false
	if not actorId in wf.sendActors:
		return false

	var messages = wf.get_env_array("攻击宣言")
	var msg = "苟不能为辅国良臣\n也须做得乱世枭雄！\n（【{0}】首次出征无须命令书".format([
		ske.skill_name,
	])
	messages.append([msg, actorId, 0])
	wf.set_env("攻击宣言", messages)
	wf.set_env("不消耗命令书", 1)
	return false
