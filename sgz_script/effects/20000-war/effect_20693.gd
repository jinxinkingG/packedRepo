extends "effect_20000.gd"

# 怨灭锁定技
#【怨灭】大战场，规则技。回合开始和结束阶段，若场上没有“缠怨”目标，你退出「怨魂」状态。\n缠怨目标：<varname:0:-1>。

func on_trigger_20013() -> bool:
	return check_status()

func on_trigger_20016() -> bool:
	return check_status()

func check_status() -> bool:
	var fromId = ske.get_war_skill_val_int()
	if fromId < 0:
		return false

	var wa = DataManager.get_war_actor(fromId)
	if wa == null or wa.disabled:
		me.set_war_side("")
		var msg = "魂散怨消……\n（退出「魂」面"
		me.attach_free_dialog(msg, 2)
	return false
