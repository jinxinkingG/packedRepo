extends "effect_20000.gd"

#雄莽锁定技 #禁用技能 #全体
#【雄莽】大战场，锁定技。每次你转移阵营后发动。对方全体的锁定技和诱发技直到当前回合结束前无效。（“对方”是指郝萌转移阵营之后的敌方。）

func on_trigger_20013() -> bool:
	# 记录当前阵营
	ske.set_war_skill_val(me.vstateId)
	return false

func on_trigger_20051() -> bool:
	var prevVstateId = ske.get_war_skill_val_int(-1, -1, -1)
	if prevVstateId == -1:
		prevVstateId = me.init_vstateId
	if prevVstateId < 0 or prevVstateId == me.vstateId:
		return false
	ske.set_war_skill_val(me.vstateId)

	for wa in me.get_enemy_war_actors():
		for skill in SkillHelper.get_actor_skills(wa.actorId):
			if skill.type in ["锁定", "诱发"]:
				ske.ban_war_skill(wa.actorId, skill.name, 1)

	var lordName = "敌"
	var leaderName = "诸公"
	var wv = me.war_vstate()
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader != null:
		lordName = enemyLeader.get_lord_name()
		leaderName = DataManager.get_actor_honored_title(enemyLeader.actorId, actorId)
	var msg = "今另投明主，{0}休怪！\n（{1}军全体锁定技、诱发技被禁用1回合".format([
		leaderName, lordName,
	])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	me.attach_free_dialog(msg, 0)
	return false
