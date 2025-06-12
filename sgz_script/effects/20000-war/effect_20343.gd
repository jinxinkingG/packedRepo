extends "effect_20000.gd"

#雄骑限定技 #禁用技能 #解锁技能 #全体
#【雄骑】大战场，主将限定技。启动后，直到你方下回合开始之前，你方所有武将临时获得隐藏技能<骑神>，然后本次战争结束前，你失去<铁骑>和<雄骑>。

const EFFECT_ID = 20343
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const LOST_SKILL_1 = "铁骑"
const LOST_SKILL_2 = "雄骑"
const TARGET_SKILL = "骑神"

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return

func effect_20343_start():
	var msg = "失去【{0}】【{1}】\n令全军暂时获得【{2}】\n可否？".format([
		LOST_SKILL_1, LOST_SKILL_2, TARGET_SKILL
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func effect_20343_2():
	ske.cost_war_cd(99999)
	ske.ban_war_skill(ske.skill_actorId, LOST_SKILL_1, 99999)
	ske.ban_war_skill(ske.skill_actorId, LOST_SKILL_2, 99999)

	ske.add_war_skill(me.actorId, TARGET_SKILL, 1)
	for wa in me.get_teammates():
		ske.add_war_skill(wa.actorId, TARGET_SKILL, 1)
	var targetName = "敌"
	var enemyLeader = me.get_enemy_leader()
	if enemyLeader != null:
		targetName = DataManager.get_actor_naughty_title(enemyLeader.actorId, actorId)
	var msg = "{0}！\n今日教尔知晓羌骑之威\n（众将暂时获得【{1}】".format([
		targetName, TARGET_SKILL
	])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	play_dialog(me.actorId, msg, 0, 2001)
	return
