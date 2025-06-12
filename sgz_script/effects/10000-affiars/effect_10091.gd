extends "effect_10000.gd"

#励商主动技
#【励商】内政，主动技。发动此技能，视为执行一次「鼓励工商」。每月限1次。

func effect_10091_start()->void:
	ske.affair_cd(1)
	var cmd = DataManager.get_current_develop_command()
	# 记录上一次开发的武将，避免被励商打断
	var lastActionId = cmd.lastActionId
	cmd = DataManager.new_develop_command("产业", actorId, DataManager.player_choose_city)
	cmd.decide_cost()
	cmd.realCost = 0
	cmd.execute()
	# 恢复上一次开发的武将
	cmd.lastActionId = lastActionId
	# 从播放动画开始进入正常流程
	LoadControl.end_script()
	LoadControl.load_script("affiars/town_develop.gd")
	FlowManager.add_flow("develop_6")
	return
