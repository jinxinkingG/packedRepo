extends "effect_20000.gd"

#雄乱主动技 #禁用技能 #全体
#【雄乱】大战场，主将限定技。消耗5点机动力发动：对方全体的锁定技和诱发技，直到当前回合结束前无效。若队友拥有【幕后】，第一次发动时，此技能不进入 CD。

const EFFECT_ID = 20284
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func effect_20284_start():
	if not assert_action_point(me.actorId, COST_AP):
		return
	var msg = "消耗{0}机动力\n发动【{1}】，禁用敌方锁定技和诱发技，可否？".format([
		COST_AP, ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20284_2() -> void:
	var wf = DataManager.get_current_war_fight()
	ske.cost_ap(COST_AP, true)

	# 还原【幕后】武将 id
	var backed = ske.get_war_skill_val_int_array()
	if backed.size() == 2:
		if wf.date == backed[1]:
			# 当天立刻又发动了？！
			backed[1] = -1
			ske.set_war_skill_val(backed)
		else:
			# 清除标记
			ske.set_war_skill_val([])
	else:
		for teammate in me.war_vstate().get_war_actors(false, true):
			if teammate.actorId == actorId:
				continue
			if SkillHelper.actor_has_skills(teammate.actorId, ["幕后"], false):
				backed = [teammate.actorId, wf.date]
				ske.set_war_skill_val(backed)
				break
	if backed.size() == 2 and backed[1] == wf.date:
		pass
	else:
		ske.cost_war_cd(99999)

	for wa in me.get_enemy_war_actors():
		for skill in SkillHelper.get_actor_skills(wa.actorId):
			if skill.type in ["锁定", "诱发"]:
				ske.ban_war_skill(wa.actorId, skill.name, 1)

	var lordName = "敌"
	var wv = me.war_vstate()
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader != null:
		lordName = enemyLeader.get_lord_name()
	var msg = "天下乱世，我岂不为枭雄！\n（{0}军全体锁定技、诱发技被禁用1回合".format([
		lordName,
	])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20284_3() -> void:
	# 还原【幕后】武将 id
	var backed = ske.get_war_skill_val_int_array()
	if backed.size() != 2:
		skill_end_clear()
		FlowManager.add_flow("player_skill_end_trigger")
		return
	var backedActorId = backed[0]
	var date = backed[1]
	var wf = DataManager.get_current_war_fight()
	var msg = "将军之断是也\n世道非常，非乱何以求治\n（【幕后】触发\n（{0}【{1}】冷却恢复".format([
		actor.get_name(), ske.skill_name,
	])
	if date == -1:
		# 当天立刻又发动了？！
		msg = "将军不见机，谬矣\n乱上加乱，有何益处？"
	play_dialog(backed[0], msg, 2, 2999)
	return
