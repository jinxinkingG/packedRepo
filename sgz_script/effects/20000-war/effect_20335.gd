extends "effect_20000.gd"

#名士锁定效果
#【名士】大战场，锁定技。战争前10日，你方人数>1时，若你未进行过攻击/用计，则对方不能对你进行攻击/用计。

func on_trigger_20012()->bool:
	# 计策结束
	_disable_buff()
	return false

func on_trigger_20015()->bool:
	# 进入白兵战
	_disable_buff()
	return false

func on_trigger_20030()->bool:
	if _buff_disabled():
		return false
	var excludedTargets = DataManager.get_env_dict("战争.攻击目标排除")
	excludedTargets[me.actorId] = ske.skill_name
	DataManager.set_env("战争.攻击目标排除", excludedTargets)
	return false

# 关闭名士状态
func _disable_buff()->void:
	ske.set_war_skill_val(1, 99999)
	return

# 名士状态是否已失效
func _buff_disabled()->bool:
	var wf = DataManager.get_current_war_fight()
	return wf.date > 10 or ske.get_war_skill_val_int() > 0
