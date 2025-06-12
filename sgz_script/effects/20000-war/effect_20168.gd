extends "effect_20000.gd"

#讲武主动技 #消耗标记 #获取经验 #连续发动
#【讲武】大战场,主动技。你可以消耗20[备]，指定一个你方等级不高于你的武将，该武将经验+（500+5X），X=受教武将的等级，每个回合限3次。

const EFFECT_ID = 20168
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const FLAG_NAME = "备"
const FLAG_SCENE_ID = 10000
const FLAG_ID = 10025

const FLAG_COST = 20
const EXP_GAIN = 500

const TIPS = [
	"戰也，貴勝，久則鈍兵挫銳",
	"全軍為上，破軍次之",
	"不可勝在己，可勝在敵",
	"奇正相生，如循環之無端",
	"故策之而知得失之計",
	"其疾如風，其徐如林",
	"近而靜者，恃其險也",
	"料敵制勝，上將之道也",
]

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", true)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func on_view_model_2003():
	wait_for_skill_result_confirmation(FLOW_BASE + "_5")
	return

# 发动主动技
func effect_20168_start():
	if not assert_flag_count(me.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, FLAG_COST):
		return

	if ske.get_war_limited_times() >= 3:
		var msg = "将之道，当循序渐进\n（【{0}】每日限三次".format([ske.skill_name])
		LoadControl._error(msg, me.actorId)
		return

	var targets = []
	for targetId in get_teammate_targets(me):
		var targetActor = ActorHelper.actor(targetId)
		if targetActor.get_level() > actor.get_level():
			continue
		targets.append(targetId)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定队友
func effect_20168_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var msg = "消耗{0}[{1}]发动【{3}】\n向{2}传授为将之道\n可否？".format([
		FLAG_COST, FLAG_NAME, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20168_3():
	var msg = TIPS[randi() % TIPS.size()] + "\n……　……\n……"
	play_dialog(me.actorId, msg, 2, 2002)
	return

func effect_20168_4():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	ske.cost_war_limited_times(3)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, FLAG_COST)
	var exp_gain = EXP_GAIN + 5 * targetActor.get_level()
	exp_gain = ske.change_actor_exp(targetId, exp_gain)

	var msg = "多谢{0}\n在下当时时铭记\n（{1}获得{2}经验".format([
		DataManager.get_actor_honored_title(me.actorId, targetId),
		targetActor.get_name(), exp_gain,
	])
	# 已经交代得比较清楚了，只记日志
	ske.war_report()
	play_dialog(targetId, msg, 2, 2003)
	return

func effect_20168_5():
	if ske.get_war_cd() > 0:
		FlowManager.add_flow("player_skill_end_trigger")
		return
	ske.reset_for_redo()
	FlowManager.add_flow(FLOW_BASE + "_start")
	return

