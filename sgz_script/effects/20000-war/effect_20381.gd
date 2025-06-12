extends "effect_20000.gd"

#截宝锁定技
#【截宝】大战场&小战场，锁定技。你击杀/俘虏敌将时，若其携带S级道具，你可选择将其道具置入装备库，并令对方免疫那次死亡。

const EFFECT_ID = 20381
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20381_AI_start():
	goto_step("2")
	return

func effect_20381_start():
	var targetId = get_env_int("战争.截宝.目标")
	var targetActor = ActorHelper.actor(targetId)

	# 如果是计策引发的，禁止计策的连策
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1

	var msg = "{0}身怀宝物\n截夺宝物，放其生还\n可否？".format([
		targetActor.get_name(),
	])
	play_dialog(me.actorId, msg, 1, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", false, FLOW_BASE + "_3")
	return

func effect_20381_2():
	var targetId = get_env_int("战争.截宝.目标")
	var wa = DataManager.get_war_actor(targetId)
	var targetActor = ActorHelper.actor(targetId)
	var dic = _get_recorded_status(targetId)
	ske.set_war_skill_val(null, 0, -1, targetId)

	targetActor.set_status_officed()
	var loyalty = int(dic["l"])
	for vs in clVState.all_vstates():
		if vs.is_alive() and vs.get_lord_id() == targetActor.actorId:
			loyalty = 100
	targetActor.set_loyalty(loyalty)
	targetActor.set_soldiers(dic["s"])

	# 恢复归属
	var wvId = int(dic["wv"])
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.add_war_actor(wa)
		wa.disabled = false

	targetActor.set_hp(1)
	wa.position = Vector2(dic["x"], dic["y"])

	var winnerVS = me.vstate()
	var robbed = []
	for ut in StaticManager.EQUIPMENT_TYPES:
		var equip = targetActor.get_equip(ut)
		if equip.level() != "S":
			continue
		if targetActor.set_equip(clEquip.basic_equip(ut, equip.subtype())):
			winnerVS.add_stored_equipment(equip)
			robbed.append(equip.name())

	var msg = "放尔生路，再犯不饶！\n（已夺取{1}入库"
	var mood = 0
	var robInfo = ""
	if robbed.empty():
		msg = "好生奇怪 ……\n为何无事发生？"
		mood = 3
	else:
		robInfo = "、".join(robbed)
	msg = msg.format([
		targetActor.get_name(), robInfo,
	])
	ske.append_message("免于战败", wa.actorId)
	ske.war_report()

	play_dialog(actorId, msg, mood, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation("")
	return

func effect_20381_3():
	LoadControl.end_script()
	return

func on_trigger_20027()->bool:
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	var reason = get_env_str("战争.DISABLE.TYPE")
	var source = get_env_str("战争.DISABLE.SOURCE")
	if not reason in ["俘虏", "阵亡"]:
		return false
	if not source in ["计策", "单挑", "白兵"]:
		return false
	var targetActor = ActorHelper.actor(wa.actorId)
	var valuable = false
	for ut in StaticManager.EQUIPMENT_TYPES:
		var equip = targetActor.get_equip(ut)
		if equip.level() == "S":
			valuable = true
			break
	if not valuable:
		return false
	# 记录士兵数和当前位置
	var dic = {
		"l": targetActor.get_loyalty(),
		"s": targetActor.get_soldiers(),
		"v": wa.vstate().id,
		"wv": wa.wvId,
		"x": wa.position.x,
		"y": wa.position.y
	}
	ske.set_war_skill_val(dic, 1, -1, wa.actorId)
	return false

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	if bf.loserId < 0 or bf.loserId == me.actorId:
		return false
	var target = bf.get_loser()
	if target == null or not target.disabled:
		return false
	var dic = _get_recorded_status(target.actorId)
	if dic.empty():
		return false
	var targetActor = ActorHelper.actor(target.actorId)
	# 白兵结束后是可能触发抢夺装备的
	# 所以需要再判断一次
	var valuable = false
	for ut in StaticManager.EQUIPMENT_TYPES:
		var equip = targetActor.get_equip(ut)
		if equip.level() == "S":
			valuable = true
			break
	if not valuable:
		return false
	if targetActor.is_status_dead() or targetActor.is_status_captured():
		set_env("战争.截宝.目标", targetActor.actorId)
		return true
	return false

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(me.actorId) != me.actorId:
		return false
	var wa = DataManager.get_war_actor(se.targetId)
	if wa == null or not wa.disabled:
		return false
	var dic = _get_recorded_status(wa.actorId)
	if dic.empty():
		return false
	var targetActor = ActorHelper.actor(wa.actorId)
	if targetActor.is_status_dead() or targetActor.is_status_captured():
		set_env("战争.截宝.目标", targetActor.actorId)
		return true
	return false

func _get_recorded_status(targetId:int)->Dictionary:
	var dic = ske.get_war_skill_val_dic(-1, targetId)
	for key in ["l", "s", "v", "wv", "x", "y"]:
		if not dic.has(key):
			return {}
		dic[key] = int(dic[key])
	return dic
