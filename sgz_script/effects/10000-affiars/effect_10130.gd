extends "effect_10000.gd"

# 图治主动技
#【图治】内政，转换技-主动技。你为君主，连续三次战争胜利后，你可主动发动，转为 <阳>。

const EFFECT_ID = 10130
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func get_ext_info(flat:bool=false) -> String:
	var history = SkillHelper.get_skill_variable_int_array(10000, EFFECT_ID, actorId)
	return repr_ext_info(history)

func repr_ext_info(history:PoolIntArray, flat:bool=false) -> String:
	var info = "当前状态：[color=blue]无记录[/color]"
	if history.size() != 2:
		return info
	if history[1] <= 0:
		return info
	match history[0]:
		1:
			info = "当前连胜：[color=blue]{0}[/color]".format([history[1]])
		-1:
			info = "当前连败：[color=blue]{0}[/color]".format([history[1]])
	if flat:
		info = info.replace("[color=blue]", "")
		info = info.replace("[/color]", "")
	return info

func on_trigger_10024() -> bool:
	var wvId = DataManager.get_env_int("内政.战后.wvId")
	var wf = DataManager.get_current_war_fight()
	var wv = wf.get_war_vstate(wvId)
	if wv == null:
		return false
	if wv.get_lord_id() != actorId:
		# 我不是君主，不触发
		return false
	var history = ske.affair_get_skill_val_int_array()
	if history.size() != 2:
		history = [0, 0]
	if wv.lose_reason == wv.Lose_ReasonEnum.NotLose:
		# 胜利了
		if history[0] == 1:
			history[1] += 1
		else:
			history = [1, 1]
	else:
		# 失败了
		if history[0] == -1:
			history[1] += 1
		else:
			history = [-1, 1]
	ske.affair_set_skill_val(history)
	return false

func effect_10130_start() -> void:
	var target = "阳"
	var flagRequired = 1
	if actor.is_face_positive():
		target = "阴"
		flagRequired = -1
	var history = ske.affair_get_skill_val_int_array()
	if history.size() != 2 \
		or history[0] != flagRequired \
		or history[1] < 3:
		var msg = "{0}\n不可发动【{1}】".format([
			repr_ext_info(history, true), ske.skill_name,
		])
		play_dialog(actorId, msg, 2, 2999)
		return

	var msg = "将转为 <{0}> 面\n可否？".format([
		target
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_10130_confirmed() -> void:
	var msg = "吾横扫六合，谁堪抵挡？\n然马上可定乱，不可以服人\n当布王道，天下治，方称吾心"
	if actor.is_face_positive():
		msg = "逆贼横行，豺虎当道\n墨守成规，何以平乱？\n休教天下人负我！"
		actor.set_face(false)
	else:
		actor.set_face(true)

	play_dialog(actorId, msg, 2, 2999)
	return
