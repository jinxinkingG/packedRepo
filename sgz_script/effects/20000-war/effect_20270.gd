extends "effect_20000.gd"

#诈取被动触发判断
#【诈取】大战场，锁定技。你于大战场/小战场/单挑中体力变为0的场合发动。免疫那次死亡/俘虏，你的体力回复至满值。若对方没有拥有「看破」的武将，且你不是主将，则回到主将身边。每5回合限1次。

func on_trigger_20027()->bool:
	if me.disabled:
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

func on_trigger_20012()->bool:
	# 计策结束后
	var se = DataManager.get_current_stratagem_execution()
	if se.targetId != me.actorId:
		return false
	return check_defeated()

func on_trigger_20020()->bool:
	# 小战场结束后
	var bf = DataManager.get_current_battle_fight()
	if not me.actorId in [bf.get_attacker_id(), bf.get_defender_id()]:
		return false
	return check_defeated()

func check_defeated()->bool:
	if not me.disabled:
		return false
	var action = ""
	if actor.is_status_dead():
		action = "诈死"
	elif actor.is_status_captured():
		action = "诈降"
	else:
		return false
	# 战败了
	var dic = _get_recorded_status()
	if dic.empty():
		# 没有记录，无法发动
		return false

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
	actor.set_hp(actor.get_max_hp())
	ske.append_message("免于战败", me.actorId)

	# 检查看破
	var canFlee = true
	var seeThroughActorId = -1
	if me.get_main_actor_id() == me.actorId:
		# 主将无法遁走
		canFlee = false
	var msg = "敌军好生势大！\n多亏我{0}机智，{1}逃得性命".format([
		DataManager.get_actor_self_title(me.actorId),
		action
	])
	var leader = me.get_leader()
	if leader == null or leader.disabled or not leader.has_position():
		canFlee = false
	if canFlee:
		for enemyId in get_enemy_targets(me, true, 99):
			if SkillHelper.actor_has_skills(enemyId, ["看破"]):
				# 被看破，无法遁走
				canFlee = false
				seeThroughActorId = enemyId
				break
	var newPos = null
	if canFlee:
		# 可遁走，回到主将身边，并直接结束
		var maxDistance = -1
		for dir in StaticManager.NEARBY_DIRECTIONS:
			var pos = leader.position + dir
			if not me.can_move_to_position(pos):
				continue
			var distance = Global.get_distance(pos, me.position)
			if distance > maxDistance:
				newPos = pos
				maxDistance = distance
	if newPos != null:
		# 有位置，拉回来
		ske.change_war_actor_position(me.actorId, newPos)
	else:
		# 无法遁走，留在原地
		var pos = Vector2(dic["x"], dic["y"])
		var existed = DataManager.get_war_actor_by_position(pos)
		if existed == null:
			me.position = pos
		else:
			# 设为待布阵
			me.position = Vector2(-1, -1)
	me.attach_free_dialog(msg, 1)
	if seeThroughActorId >= 0:
		# 被看破，插入发动者和看破者的对话
		var extraMsg = "诈死偷生，也算手段\n只是究竟能逃到哪里去？"
		# 为了保证对话顺序，都 attach 到自己身上
		me.attach_free_dialog(extraMsg, 2, 20000, seeThroughActorId)

	ske.war_report()
	return false

func _get_recorded_status()->Dictionary:
	var dic = ske.get_war_skill_val_dic()
	for key in ["l", "s", "v", "wv", "x", "y"]:
		if not dic.has(key):
			return {}
		dic[key] = int(dic[key])
	return dic
