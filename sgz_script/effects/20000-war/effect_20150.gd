extends "effect_20000.gd"

#再起主动技 #消耗标记 #回复兵力
#【再起】大战场,主动技。战争初始，你获得6个[起]标记。若你方金>200，你可以消耗1个[起]标记和100金发动：你的士兵+500。战争结束你遣散临时征募的士兵。

const EFFECT_ID = 20150
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "起"
const FLAG_INIT_COUNT = 6
const GOLD_COST = 100
const GOLD_REQUIRED = 200

# 锁定技部分，第一次出战给标记
func on_trigger_20013():
	var dic = ske.get_war_skill_val_dic()
	if not dic.has("flagInit"):
		dic["flags"] = {FLAG_NAME: FLAG_INIT_COUNT}
		dic["flagInit"] = 1
		ske.set_war_skill_val(dic)
		ske.append_message("首次出战，获得{0}个[{1}]".format([
			FLAG_INIT_COUNT, FLAG_NAME,
		]))
		ske.war_report()
	return false

# 发动主动技
func effect_20150_start():
	var wv = me.war_vstate()

	if wv.money < GOLD_REQUIRED:
		var msg = "金不足，发动【{1}】需\n金 >= {0}".format([
			GOLD_REQUIRED, ske.skill_name
		])
		play_dialog(me.actorId, msg, 3, 2099)
		return

	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	if flags <= 0:
		var msg = "[{0}]不足，无法发动【{1}】".format([FLAG_NAME, ske.skill_name])
		play_dialog(me.actorId, msg, 3, 2099)
		return

	var maxSoldiers = DataManager.get_actor_max_soldiers(me.actorId)
	if actor.get_soldiers() >= maxSoldiers:
		var msg = "兵力充足，无须【{0}】".format([ske.skill_name])
		play_dialog(me.actorId, msg, 1, 2099)
		return

	var msg = "消耗 100 金和一个[{0}]\n发动【{1}】补充兵力\n可否？".format([
		FLAG_NAME, ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2000, true)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2")
	return

func effect_20150_2():
	ske.cost_skill_flags(20000, EFFECT_ID, FLAG_NAME, 1)
	ske.cost_wv_gold(GOLD_COST)
	ske.add_war_tmp_soldier(ske.skill_actorId, 500, -1)

	var nick = "本将"
	if me.actorId == StaticManager.ACTOR_ID_MENGHUO:
		nick = "本王"
	var msg ="{0}不服，定东山再起！".format([nick])
	var nextViewModel = 2009
	if me.get_controlNo() < 0:
		nextViewModel = 3009
	report_skill_result_message(ske, nextViewModel, msg, 0)
	return

func on_view_model_2009():
	wait_for_pending_message(FLOW_BASE + "_3")
	return

func effect_20150_3():
	report_skill_result_message(ske, 2009)
	return

func on_view_model_2099():
	wait_for_skill_result_confirmation()
	return

func check_AI_perform_20000()->bool:
	var wv = me.war_vstate()
	if wv.money < GOLD_REQUIRED:
		return false
	var flags = SkillHelper.get_skill_flags_number(20000, EFFECT_ID, me.actorId, FLAG_NAME)
	if flags <= 0:
		return false
	var limit = DataManager.get_actor_max_soldiers(me.actorId)
	if actor.get_soldiers() > 2500:
		return false
	if actor.get_soldiers() > limit - 500:
		return false
	return true

func effect_20150_AI_start():
	goto_step("2")
	return

func effect_20150_AI_2():
	report_skill_result_message(ske, 3009)
	return

func on_view_model_3009():
	wait_for_pending_message(FLOW_BASE + "_AI_2", "AI_skill_end_trigger")
	return
