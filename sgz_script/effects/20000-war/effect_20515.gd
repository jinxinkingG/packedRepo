extends "effect_20270.gd"

#烈肤被动触发判断
#【烈肤】大战场，锁定技。你于大战场/小战场/单挑中体力变为0的场合发动。免疫那次死亡/俘虏，你的体力上限减半（持续到本场战争结束前），然后你的体力回满。每5回合限1次。

# 覆写诈取的复活效果，其他逻辑继承自诈取
func check_defeated()->bool:
	if not me.disabled:
		return false
	# 战败了
	var dic = _get_recorded_status()
	if dic.empty():
		# 没有记录，无法发动
		return false
	var maxHP = actor.get_max_hp()
	var reduce = int(maxHP / 2)
	reduce = min(reduce, maxHP - 10)
	if reduce > 0:
		ske.change_actor_max_hp(actorId, -reduce)

	# 处理技能效果
	ske.cost_war_cd(5)
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
	maxHP = actor.get_max_hp()
	actor.set_hp(maxHP)
	ske.append_message("免于战败", actorId)

	var msg = "存亡之分，可披创而战！\n（【{0}】避免战败\n（体力上限现为{1}".format([
		ske.skill_name, maxHP,
	])
	var pos = Vector2(dic["x"], dic["y"])
	var existed = DataManager.get_war_actor_by_position(pos)
	if existed == null:
		me.position = pos
	else:
		# 设为待布阵
		me.position = Vector2(-1, -1)
	me.attach_free_dialog(msg, 1)

	ske.war_report()
	return false
