extends "effect_20000.gd"

#震塞主动技 #禁用技能 #全体
#【震塞】大战场，主将限定技。启动后，直到你方下回合开始之前，你方所有武将临时获得隐藏技能<弓骑>，然后本次战争结束前，你失去<义从>和<震塞>。

const EFFECT_ID = 20438
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LOST_SKILL = "义从"
const TARGET_SKILL = "弓骑"

func effect_20438_start():
	var msg = "失去【{0}】【{1}】\n令全军暂时获得【{2}】\n可否？".format([
		ske.skill_name, LOST_SKILL, TARGET_SKILL
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20438_2():
	ske.cost_war_cd(99999)
	ske.ban_war_skill(me.actorId, ske.skill_name, 99999)
	ske.ban_war_skill(me.actorId, LOST_SKILL, 99999)

	ske.add_war_skill(me.actorId, TARGET_SKILL, 1)
	for wa in me.get_teammates(false):
		ske.add_war_skill(wa.actorId, TARGET_SKILL, 1)
	var targetName = "小儿"
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader != null:
		targetName = DataManager.get_actor_naughty_title(enemyLeader.actorId, actorId)
	var msg = "吾白马扬威边塞之时\n几曾见{0}逞狂！\n（众将暂时获得【{1}】".format([
		targetName, TARGET_SKILL
	])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
