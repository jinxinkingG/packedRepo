extends "effect_20000.gd"

#咒符主动技 #计伤
#【咒符】大战场，主动技。你可以指定一个对方武将，消耗6点机动力,发动黄巾军秘术，你对该武将结算一次要击计策伤害，机动力-3，每个回合限1次。

const EFFECT_ID = 20314
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 6
const DAMAGE_AP = 3
const STRATAGEM = "要击"

func check_AI_perform_20000()->bool:
	if me.action_point < COST_AP:
		return false
	var maxScore = 300
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		var score = wa.get_soldiers() + wa.action_point * 100
		if score > maxScore:
			return true
	return false

func effect_20314_AI_start()->void:
	# 先设 CD 避免重入
	ske.cost_war_cd(1)
	var maxScore = 300
	var target = null
	for targetId in get_enemy_targets(me):
		var wa = DataManager.get_war_actor(targetId)
		var score = wa.get_soldiers() + wa.action_point * 100
		if score > maxScore:
			maxScore = score
			target = wa
	if target == null:
		skill_end_clear()
		return
	DataManager.set_env("目标", target.actorId)
	goto_step("3")
	return

# 发动主动技
func effect_20314_start():
	if not assert_action_point(me.actorId, COST_AP):
		return

	if not wait_choose_actors(get_enemy_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定对手
func effect_20314_2():
	var targetId = get_env_int("目标")
	var msg = "消耗{0}机动力\n对{1}发动【咒符】\n可否？".format([
		COST_AP, ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

# 确认后播放动画
func effect_20314_3():
	var se = DataManager.new_stratagem_execution(actorId, STRATAGEM)
	se.work_as_skill = 1
	se.set_target(DataManager.get_env_int("目标"))

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	var apReduced = ske.change_actor_ap(se.targetId, -DAMAGE_AP)
	ske.war_report()
	se.perform_to_targets([se.targetId], true)
	var targetWA = DataManager.get_war_actor(se.targetId)
	if apReduced < 0:
		var msg = "机动力 {0}，现为 {1}".format([apReduced, targetWA.action_point])
		if targetWA.get_controlNo() < 0:
			# 玩家汇报 AI 的情况
			msg = targetWA.get_name() + msg
		se.append_result("", msg, apReduced, se.targetId)

	var msg = "{0}实乃心腹之患\n秘术咒之！".format([
		ActorHelper.actor(se.targetId).get_name()
	])

	ske.play_se_animation(se, 2002, msg, 0)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20314_report():
	var se = DataManager.get_current_stratagem_execution()
	report_stratagem_result_message(se, 2002)
	return
