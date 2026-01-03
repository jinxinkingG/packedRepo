extends "effect_20000.gd"

#恩绝主动技
#【恩绝】大战场，限定技。刷新敌方主将点数，若你的点数比对方大：直到回合结束前禁用其「锁定」和「主将」类技能；否则，你立刻执行一次机动力恢复。若以此法禁用了敌将技能，己方对攻击那名敌将时，解除封禁效果。

const EFFECT_ID = 20523
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20523_start() -> void:
	var enemyLeader = me.get_enemy_leader()
	var msg = "发动限定技【{0}】\n本回合禁用{1}的锁定技和主将技，可否？".format([
		ske.skill_name, enemyLeader.get_name(),
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000() -> void:
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20523_2() -> void:
	var enemyLeader = me.get_enemy_leader()

	ske.cost_war_cd(99999)
	ske.change_actor_five_phases(enemyLeader.actorId, enemyLeader.five_phases, -1)

	var msg = "新恨既生，旧恩难续！\n（{0}发动【{1}】\n（{2}的点数刷新为 {3}".format([
		me.get_name(), ske.skill_name,
		enemyLeader.get_name(), enemyLeader.poker_point
	])
	play_dialog(actorId, msg, 0, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20523_3() -> void:
	var enemyLeader = me.get_enemy_leader()

	if me.get_poker_point_diff(enemyLeader) <= 0:
		var current = me.action_point
		me.recharge_action_point()
		var recharged = me.action_point
		me.action_point = current
		recharged = ske.change_actor_ap(actorId, recharged)
		ske.war_report()

		var msg = "时也，运也！\n（点数 {0} <= {1}点数 {2}\n（机动力回复 {3} -> {4}".format([
			me.poker_point, enemyLeader.get_name(),
			enemyLeader.poker_point, recharged, me.action_point
		])
		play_dialog(actorId, msg, 3, 2999)
		return

	var banned = []
	for skill in SkillHelper.get_actor_skills(enemyLeader.actorId, 20000):
		if skill.type == "锁定" or skill.has_feature("主将"):
			if ske.ban_war_skill(enemyLeader.actorId, skill.name, 1):
				banned.append(skill.name)
	ske.set_war_skill_val(banned, 1, -1, enemyLeader.actorId)
	ske.war_report()

	var msg = "足下与{0}，各安其命！".format([
		actor.get_short_name(), enemyLeader.get_name(),
	])
	goto_step("report")
	return

func effect_20523_report() -> void:
	report_skill_result_message(ske, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_pending_message(FLOW_BASE + "_report")
	return
