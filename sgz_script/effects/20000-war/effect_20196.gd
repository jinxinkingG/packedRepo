extends "effect_20000.gd"

#雄异限定技 #禁用技能 #机动力 #全体
#【雄异】大战场，主将限定技。启动后，你方所有武将机动力增加你的机动力值（至多增加15点）。若如此，直到战争结束前，你失去<马术>和<雄异>。

const EFFECT_ID = 20196
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const AP_LIMIT = 15

const LOST_SKILL = "马术"

func effect_20196_start():
	if me.action_point <= 0:
		var msg = "当前无可用机动力\n发动【{0}】毫无意义".format([ske.skill_name])
		play_dialog(me.actorId, msg, 2, 2001)
		return

	var msg = "发动【{0}】失去【{1}】\n全军机动力增加{2}\n可否？".format([
		ske.skill_name, LOST_SKILL, min(AP_LIMIT, me.action_point)
	])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20196_2():
	ske.cost_war_cd(99999)
	ske.ban_war_skill(ske.skill_actorId, LOST_SKILL, 99999)
	ske.ban_war_skill(ske.skill_actorId, ske.skill_name, 99999)

	var ap = min(AP_LIMIT, me.action_point)
	var targets = get_teammate_targets(me, 999)
	targets.append(me.actorId)
	for targetId in targets:
		ske.change_actor_ap(targetId, ap, false)
	var msg = "奔雷逐北，胜败在此一举！\n（众将机动力回复{0}".format([ap])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)
	play_dialog(actorId, msg, 0, 2999)
	return
