extends "effect_20000.gd"

#义绝主动技 #拼点 #施加状态
#【义绝】大战场,主动技。每个回合限1次，若你未进行过攻击，选择1名敌将发动，立即刷新对方五行。若你点数比目标点数大，目标武将直到回合结束前技能失效；否则，恢复10点体力，且你本回合内不可进行攻击和移动。可对城地形目标发动。

const EFFECT_ID = 20032
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const HP_RECOVER = 10

func effect_20032_start() -> void:
	var wf = DataManager.get_current_war_fight()
	if not me.get_day_attacked_actors(wf.date).empty():
		var msg = "已进行过攻击\n不能发动"
		play_dialog(me.actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(get_enemy_targets(me, true)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected")
	return

#确认发动
func effect_20032_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "是否对{2}使用{3}？\n({0}当前五行|点数:{1})".format([
		actor.get_name(), me.get_five_phases_str() + me.get_poker_point_str(),
		targetActor.get_name(), ske.skill_name
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed")
	return

func effect_20032_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	
	ske.cost_war_cd(1)

	var point = Global.get_random(0, 9)
	ske.change_actor_five_phases(targetId, targetWA.five_phases, point)

	var msg = "吾向来恩怨分明!\n（敌将点数刷新为{0}".format([targetWA.poker_point])
	ske.play_war_animation("Strategy_Talking", 2002, targetId, msg, 2)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_perform")
	return

func effect_20032_perform() -> void:
	var targetId = DataManager.get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)

	var msg = "将军之恩，某早已报过！"
	if targetWA.poker_point >= me.poker_point:
		ske.set_war_buff(me.actorId, "禁止攻击移动", 1)
		ske.change_actor_hp(me.actorId, HP_RECOVER)
		msg = "义字不可违，君恩不敢忘！"
	else:
		ske.set_war_buff(targetId, "沉默", 1)
	ske.war_report()

	report_skill_result_message(ske, 2003, msg, 3)
	return

func on_view_model_2003():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20032_report() -> void:
	report_skill_result_message(ske, 2003)
	return
