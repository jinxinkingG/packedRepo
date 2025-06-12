extends "effect_30000.gd"

#枭行锁定技
#【枭行】小战场，锁定技。白刃战初始，令对方选择「是否在本次白刃战中，废弃自身所有装备的附加效果」。若对方选择否：直到战斗结束前，你的行动次数+1。

func on_trigger_30005()->bool:
	# 固定发动
	return true

func effect_30203_AI_start():
	goto_step("start")
	return

func effect_30203_start():
	if enemy.get_controlNo() < 0:
		var options = [0, 1]
		# 对手为 AI，随机选择
		options.shuffle()
		DataManager.set_env("枭行.选项", options[0])
		goto_step("2")
		return
	# 对手为玩家，令玩家选择
	var msg = "{0}发动【{1}】\n作何选择？".format([
		me.get_name(), ske.skill_name,
	])
	var options = ["放弃武器特性", "{0}获得三动".format([me.get_name()])]
	SceneManager.show_yn_dialog(msg, -1, 2, options)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	var option = wait_for_skill_option()
	if option >= 0:
		DataManager.set_env("枭行.选项", option)
		goto_step("2")
	return

func effect_30203_2():
	var option = DataManager.get_env_int("枭行.选项")
	var msg = ""
	var speaker = enemy
	if option == 0:
		var bu = get_leader_unit(enemy.actorId)
		if bu == null:
			LoadControl.end_script()
			return
		bu.dic_combat["武器特性"] = []
		msg = "不论兵刃又如何！\n尔能胜我？\n（已放弃武器特性"
	else:
		var bu = get_leader_unit(me.actorId)
		if bu == null:
			LoadControl.end_script()
			return
		bu.set_action_times(3, true)
		msg = "草原健儿之勇\n今日教尔知晓！\n（获得额外行动次数"
		speaker = me
	skill_end_clear()
	speaker.attach_free_dialog(msg, 0, 30000)
	return
