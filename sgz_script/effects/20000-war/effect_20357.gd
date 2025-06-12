extends "effect_20000.gd"

#幸宽主动技 #回营 #施加状态
#【幸宽】大战场，锁定技。你非主将时，你方其他非主将队友在你4格内，也可以发动使其回营，每执行一次，你获得2回合 {迟滞}。每回合限一次

const EFFECT_ID = 20357
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_BUFF = "迟滞"
const COST_BUFF_TURNS = 2

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

func on_view_model_2009():
	wait_for_skill_result_confirmation()
	return

# 发动主动技
func effect_20357_start():
	var targets = get_teammate_targets(me, 4)
	targets.erase(me.get_main_actor_id())
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定队友
func effect_20357_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "以自身迟滞为代价\n令{0}回营\n可否？".format([
		targetActor.get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

# 执行
func effect_20357_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(1)
	ske.war_camp_in(targetId)
	
	var turns = me.get_buff(COST_BUFF)["回合数"] + COST_BUFF_TURNS
	ske.set_war_buff(me.actorId, COST_BUFF, turns)

	var msg = "{0}所在不利\n可先回营，寻机再战".format([
		DataManager.get_actor_honored_title(targetId, me.actorId)
	])
	report_skill_result_message(ske, 2002, msg, 2)
	return

func effect_20357_4():
	var ske = SkillHelper.read_skill_effectinfo()
	report_skill_result_message(ske, 2002)
	return
