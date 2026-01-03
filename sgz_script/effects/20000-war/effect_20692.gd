extends "effect_20000.gd"

# 躯灭锁定技
#【躯灭】大战场，锁定技。你死亡/被俘时，免疫那次死亡/俘虏，进入 {怨魂} 状态，并把击杀你的武将标志为“缠怨”目标。战争中限1次。

const GHOST_EFFECT_ID = 20693

func on_trigger_20027() -> bool:
	if me.disabled:
		return false
	if not actor.is_status_dead() and not actor.is_status_captured():
		return false
	var fromId = DataManager.get_env_int("战争.DISABLE.FROM")
	if fromId < 0:
		return false
	# 记录士兵数和当前位置
	var dic = {
		"l": actor.get_loyalty(),
		"s": actor.get_soldiers(),
		"v": me.vstate().id,
		"wv": me.wvId,
		"x": me.position.x,
		"y": me.position.y,
		"from": fromId,
	}
	ske.set_war_skill_val(dic, 1)
	return false

func on_trigger_20012() -> bool:
	if not actor.is_status_dead() and not actor.is_status_captured():
		return false
	turn_ghost()
	return false

func on_trigger_20020() -> bool:
	if not actor.is_status_dead() and not actor.is_status_captured():
		return false
	turn_ghost()
	return false

func turn_ghost() -> bool:

	# 战败了
	var dic = ske.get_war_skill_val_dic()
	if dic.empty():
		# 没有记录，无法发动
		return false

	# 缠怨目标
	var fromId = int(dic["from"])
	if fromId < 0:
		return false

	# 处理技能效果
	ske.cost_war_cd(99999)
	ske.set_war_skill_val({}, 0)

	# 如果是计策引发的，禁止计策的连策
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1

	# 恢复状态
	actor.set_status_officed()
	var loyalty = int(dic["l"])
	for vs in clVState.all_vstates():
		if vs.is_alive() and vs.get_lord_id() == actor.actorId:
			loyalty = 100
	actor.set_loyalty(loyalty)
	actor.set_soldiers(dic["s"])

	# 恢复归属
	var wvId = int(dic["wv"])
	var wv = wf.get_war_vstate(wvId)
	if wv != null:
		wv.add_war_actor(me)
		me.disabled = false

	# 恢复满体
	actor.set_hp(actor.get_max_hp())
	ske.append_message("免于战败", actorId)

	# 恢复位置
	var pos = Vector2(int(dic["x"]), int(dic["y"]))
	me.position = pos
	me.set_war_side("魂")
	ske.set_war_skill_val(fromId, 99999, GHOST_EFFECT_ID)

	map.draw_actors()
	ske.war_report()

	var msg = "呵……\n{0}小儿好胆色！\n（转为「魂」面".format([
		DataManager.get_war_actor(fromId).get_name(),
	])
	me.attach_free_dialog(msg, 0)
	return true
