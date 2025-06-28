extends "effect_20000.gd"

#缓进主动技部分
#【缓进】大战场,限定技。你可以减5点机动力上限，指定一个你方武将，其获得一个[助]标记。拥有[助]的武将，若其白刃战胜利，兵力恢复本次白刃战损失兵力的50%；若其白刃战失败，该武将移动到与你最近的那格，且失去[助]标记，你机动力上限+5。

const EFFECT_ID = 20264
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const AP_LIMIT = 5

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", true)
	return

func effect_20264_start():
	var targets = get_teammate_targets(me)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20264_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "机动力上限 -{0}\n对{1}发动【缓进】\n可否？".format([
		AP_LIMIT, targetActor.get_name()
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20264_3():
	var targetId = get_env_int("目标")

	ske.cost_war_cd(99999)
	ske.set_war_skill_val(actorId, 99999, -1, targetId)
	ske.set_war_skill_val(targetId)
	ske.set_actor_extra_ap_limit(actorId, -AP_LIMIT)
	ske.war_report()

	var msg = "敌利在急战，我利在缓搏。\n吾为后劲，助{0}徐图之。\n（{1}获得 [助] 标记".format([
		DataManager.get_actor_honored_title(targetId, me.actorId),
		ActorHelper.actor(targetId).get_name()
	])
	play_dialog(me.actorId, msg, 2, -1)
	return

