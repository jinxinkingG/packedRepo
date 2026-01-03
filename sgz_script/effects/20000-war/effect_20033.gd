extends "effect_20000.gd"

#夺锐主动技 #学习技能 #禁用技能 #拼点
#【夺锐】大战场，主动技。1回合1次，若你未进行过攻击，选择1名敌将发动，立即刷新对方五行。若你点数比目标大，直到回合结束前你获得对方的1个技能；否则，你本回合内不可进行攻击和移动。可对城地形目标发动。

const EFFECT_ID = 20033
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20033_start():
	var wf = DataManager.get_current_war_fight()
	if not me.get_day_attacked_actors(wf.date).empty():
		var msg = "已进行过攻击\n不能发动"
		play_dialog(me.actorId, msg, 3, 2009)
		return
	var targets = []
	for targetId in get_enemy_targets(me, true):
		var targetSkills = SkillHelper.get_actor_skill_names(targetId)
		if targetSkills.empty():
			continue
		if "贞烈" in targetSkills:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

#确认发动
func effect_20033_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "对{2}发动【{3}】，可否？\n({0}当前五行|点数:{1})".format([
		actor.get_name(), me.get_five_phases_str() + me.get_poker_point_str(),
		targetActor.get_name(), ske.skill_name
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

#播放动画
func effect_20033_3():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	ske.cost_war_cd(1)
	targetWA.refresh_poker_random()
	var msg = "{0}当前点数:{1}\n敌将点数刷新为:{2}".format([
		actor.get_name(), me.poker_point, targetWA.poker_point
	])
	map.cursor.hide()
	
	ske.play_war_animation("Strategy_Talking", 2002, targetId, msg, 2)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20033_4():
	var targetId = get_env_int("目标")
	var targetWA = DataManager.get_war_actor(targetId)
	if me.get_poker_point_diff(targetWA) <= 0:
		ske.set_war_buff(ske.skill_actorId, "禁止攻击移动", 1)
		var msg = "夺锐未能成功！\n（{0}本日无法移动或攻击".format([actor.get_name()])
		ske.war_report()
		play_dialog(me.actorId, msg, 3, 2009)
		return
	var targetActor = ActorHelper.actor(targetId)
	var msg = "夺取{0}哪个技能？".format([targetActor.get_name()])
	play_dialog(me.actorId, msg, 2, 2003)
	var items = []
	for skillName in SkillHelper.get_actor_skill_names(targetId):
		items.append(skillName)
	bind_menu_items(items, items)
	return

func on_view_model_2003():
	wait_for_choose_skill(FLOW_BASE + "_5", true, false)
	return

func effect_20033_5():
	var targetId = get_env_int("目标")
	var skill = get_env_str("目标项")
	#对手失去该技能
	if not ske.ban_war_skill(targetId, skill, 1):
		play_dialog(me.actorId, "【{0}】不可夺取！".format([skill]), 2, 2009)
		return
	#自己获得选中的技能
	ske.add_war_skill(ske.skill_actorId, skill, 1)
	var msg = "尖锐之势，吾亦可一人夺之！"
	report_skill_result_message(ske, 2009, msg, 0)
	return

func effect_20033_6():
	report_skill_result_message(ske, 2009)
	return

func on_view_model_2009():
	wait_for_pending_message(FLOW_BASE + "_6")
	return
