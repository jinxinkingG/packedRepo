extends "effect_20000.gd"

#水督限定技 #解锁技能 #全体
#【水督】大战场,限定技。你方金＞1000时，你可以使用本技能：你方金-500，直到你方下个回合结束前，你方所有武将获得<涉水>。

const EFFECT_ID = 20161
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const TARGET_SKILL = "涉水"
const COST_GOLD = 500
const MIN_GOLD = 1000

func effect_20161_start():
	var wv = me.war_vstate()
	if wv == null or wv.money <= MIN_GOLD:
		var msg = "金不足，须 > {0}".format([MIN_GOLD])
		play_dialog(me.actorId, msg, 3, 2999)
		return

	var msg = "花费{0}金发动【{1}】\n我方全体本回合内\n获得技能【{2}】，可否？".format([
		COST_GOLD, ske.skill_name, TARGET_SKILL,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20161_2():
	ske.cost_war_cd(99999)
	ske.cost_wv_gold(COST_GOLD)

	ske.add_war_skill(me.actorId, TARGET_SKILL, 1)
	for wa in me.get_teammates(false):
		ske.add_war_skill(wa.actorId, TARGET_SKILL, 1)
	var msg = "全军听令，连舟涉水！\n（众将暂时获得【{0}】".format([
		TARGET_SKILL
	])
	# 信息太多了，不汇报，只记录
	ske.war_report()
	play_dialog(ske.skill_actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation()
	return
