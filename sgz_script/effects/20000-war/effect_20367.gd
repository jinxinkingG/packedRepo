extends "effect_20000.gd"

#复起锁定技
#【复起】大战场，锁定技。你方金＞500时，你于大战场/小战场/单挑中体力变为0的场合发动。免疫那次死亡/俘虏，强制回到大战场；金-200，你的体力恢复至40，兵力+1000（至多2500），每次战争仅限一次。

func _perform_skill():
	var dic = _get_recorded_status(ske)
	var action = ""

	ske.cost_war_cd(99999)
	ske.set_war_skill_val(null, 0)
	ske.cost_wv_gold(200)

	# 如果是计策引发的，禁止计策的连策
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1

	actor.set_status_officed()
	var loyalty = int(dic["l"])
	for vs in clVState.all_vstates():
		if vs.is_alive() and vs.get_lord_id() == actor.actorId:
			loyalty = 100
	actor.set_loyalty(loyalty)
	var soldiers = actor.get_soldiers()
	var change = min(2500 - soldiers, 1000)
	ske.change_actor_soldiers(me.actorId, change)
	
	# 恢复归属
	var wvId = int(dic["wv"])
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.add_war_actor(me)
		me.disabled = false

	actor.set_hp(40)
	var msg = "{0}家累世基业\n吾岂能绝于此地！\n（{1}发动【{2}】)".format([
		actor.get_first_name(), me.get_name(), ske.skill_name,
	])
	ske.append_message("免于战败", me.actorId)
	ske.war_report()

	me.position = Vector2(dic["x"], dic["y"])
	skill_end_clear(true)
	FlowManager.add_flow("draw_actors")
	FlowManager.add_flow("player_skill_end_trigger")
	me.attach_free_dialog(msg, 0)
	return

func on_trigger_20027()->bool:
	if me == null or me.disabled:
		return false
	# 记录士兵数和当前位置
	var dic = {
		"l": actor.get_loyalty(),
		"s": actor.get_soldiers(),
		"v": me.vstate().id,
		"wv": me.wvId,
		"x": me.position.x,
		"y": me.position.y
	}
	ske.set_war_skill_val(dic, 1)
	return false

func on_trigger_20020()->bool:
	if _defeat_and_enough_gold():
		_perform_skill()
	return false

func _defeat_and_enough_gold()->bool:
	if me == null or not me.disabled:
		return false
	var dic = _get_recorded_status(ske)
	if dic.empty():
		return false
	var wv = wf.get_war_vstate(dic["v"])
	if wv == null:
		return false
	if wv.money <= 500:
		return false
	if actor.is_status_dead() or actor.is_status_captured():
		return true
	return false

func on_trigger_20012()->bool:
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	if _defeat_and_enough_gold():
		_perform_skill()
	return false

func _get_recorded_status(ske:SkillEffectInfo)->Dictionary:
	var dic = ske.get_war_skill_val_dic()
	for key in ["l", "s", "v", "wv", "x", "y"]:
		if not dic.has(key):
			return {}
		dic[key] = int(dic[key])
	return dic
