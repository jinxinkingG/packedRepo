extends "effect_20000.gd"

#孝德被动触发判断
#【孝德】大战场，锁定技。双方与你同姓的武将死亡时，使之免疫那次死亡，回复30点体力，其技能直到战争结束前禁用，每名武将战争中只会触发一次。

const EFFECT_ID = 20341
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _get_skill_key()->String:
	return "技能.孝德.目标.{0}".format([actorId])

func on_trigger_20027()->bool:
	# 目标武将被禁用前
	DataManager.unset_env(_get_skill_key())
	if actorId == ske.actorId:
		# 不能救自己
		return false
	if me == null or me.disabled:
		return false
	var targetActor = ActorHelper.actor(ske.actorId)
	if targetActor.get_first_name() != actor.get_first_name():
		# 同姓才能救
		return false
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if _is_target_already_saved(ske.actorId):
		# 只能救一次
		return false
	var dic = _get_recorded_status()
	var k = str(ske.actorId)
	# 记录士兵数和当前位置
	dic[k] = {
		"l": targetActor.get_loyalty(),
		"s": targetActor.get_soldiers(),
		"v": wa.vstate().id,
		"wv": wa.wvId,
		"x": wa.position.x,
		"y": wa.position.y
	}
	ske.set_war_skill_val(dic, 99999)
	return false

func on_trigger_20020()->bool:
	DataManager.unset_env(_get_skill_key())
	# 小战场结束后
	if me == null or me.disabled:
		return false
	var bf = DataManager.get_current_battle_fight()
	# 这里跟诈取不同，目标已经挂了，光环技无法发动
	# 只能触发胜方来源武将
	if actorId == ske.actorId:
		# 如果是自己参战，就别发动了
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	if loser.actorId == ske.actorId:
		# 失败方不触发，也没法正常触发
		return false
	var targetActor = ActorHelper.actor(loser.actorId)
	if not targetActor.is_status_dead() and not targetActor.is_status_captured():
		# 死亡或被俘才触发
		return false
	var dic = _get_recorded_status()
	var k = str(loser.actorId)
	if not dic.has(k) or dic[k].empty():
		return false
	if _is_target_already_saved(loser.actorId):
		# 只能救一次
		return false
	DataManager.set_env(_get_skill_key(), loser.actorId)
	return true

func on_trigger_20012()->bool:
	DataManager.unset_env(_get_skill_key())
	# 计策结束后
	var se = DataManager.get_current_stratagem_execution()
	# 这里跟诈取不同，目标已经挂了，光环技无法发动
	# 只能触发计策来源武将
	if actorId == ske.actorId:
		# 自己用计干死的，就别假惺惺了
		return false
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.targetId < 0:
		return false
	var targetActor = ActorHelper.actor(se.targetId)
	if not targetActor.is_status_dead() and not targetActor.is_status_captured():
		return false
	var dic = _get_recorded_status()
	var k = str(se.targetId)
	if not dic.has(k) or dic[k].empty():
		return false
	if _is_target_already_saved(se.targetId):
		# 只能救一次
		return false
	se.skip_redo = 1
	DataManager.set_env(_get_skill_key(), se.targetId)
	return true

func effect_20341_AI_start():
	goto_step("start")
	return

func effect_20341_start():
	var targetId = DataManager.get_env_int(_get_skill_key())
	if targetId < 0:
		LoadControl.end_script()
		return
	if not _perform_save(targetId):
		LoadControl.end_script()
		return
	var targetWA = DataManager.get_war_actor(targetId)
	var speakTo = me.get_enemy_leader().actorId
	if me.is_enemy(targetWA):
		# 救敌人，自己主将说话
		speakTo = me.get_main_actor_id()
	if speakTo == actorId:
		# 自己是主将，宽恕对方武将
		var msg = "{0}与我同气连枝\n今且放过\n再若相抗，定不容情！".format([
			DataManager.get_actor_honored_title(targetId, actorId),
		])
		play_dialog(actorId, msg, 2, 2001)
		return
	var msg = "{0}与我同气连枝\n将军可否宽宥？".format([
		DataManager.get_actor_honored_title(targetId, actorId),
	])
	play_dialog(actorId, msg, 3, 2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20341_2():
	var targetId = DataManager.get_env_int(_get_skill_key())
	var wa = DataManager.get_war_actor(targetId)
	var targetWA = DataManager.get_war_actor(targetId)
	var speaker = me.get_enemy_leader().actorId
	if me.is_enemy(targetWA):
		# 救敌人，自己主将说话
		speaker = me.get_main_actor_id()
	var msg = "亲族人之本也\n然刀兵无眼\n再若相抗，定不容情！"
	play_dialog(speaker, msg, 2, 2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func _get_recorded_status()->Dictionary:
	var dic = ske.get_war_skill_val_dic()
	for k in dic:
		for attr in ["l", "s", "v", "wv", "x", "y"]:
			if not dic[k].has(attr):
				dic[k] = {}
				break
			dic[k][attr] = int(dic[k][attr])
	return dic

func _is_target_already_saved(targetId:int)->bool:
	var dic = _get_recorded_status()
	var k = str(targetId)
	if not dic.has(k):
		return false
	if dic[k].has("done") and int(dic[k]["done"]) == 1:
		return true
	return false

func _perform_save(targetId:int)->bool:
	var dic = _get_recorded_status()
	var k = str(targetId)
	if not dic.has(k):
		return false
	if dic[k].has("done") and int(dic[k]["done"]) == 1:
		return false
	dic[k]["done"] = 1
	ske.set_war_skill_val(dic, 99999)

	# 恢复状态
	var targetActor = ActorHelper.actor(targetId)
	targetActor.set_status_officed()
	var loyalty = int(dic[k]["l"])
	for vs in clVState.all_vstates():
		if vs.is_alive() and vs.get_lord_id() == targetId:
			loyalty = 100
	targetActor.set_loyalty(loyalty)
	targetActor.set_soldiers(dic[k]["s"])

	var wa = DataManager.get_war_actor(targetId)

	# 恢复归属
	var wvId = int(dic[k]["wv"])
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.add_war_actor(wa)
		wa.disabled = false

	targetActor.set_hp(30)
	var pos = Vector2(int(dic[k]["x"]), int(dic[k]["y"]))
	var existed = DataManager.get_war_actor_by_position(pos)
	if existed != null:
		# 位置被人占据，待布阵
		wa.position = Vector2(-1, -1)
	else:
		wa.position = pos
	
	for skill in SkillHelper.get_actor_skill_names(targetId):
		ske.ban_war_skill(targetId, skill, 99999)
	return true
