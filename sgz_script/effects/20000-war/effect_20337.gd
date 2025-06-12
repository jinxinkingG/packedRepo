extends "effect_20000.gd"

#谦让主动技
#【谦让】大战场，主将主动技。你可以选择一个己方其他武将，重置其已发动过的限定技。每9个回合限1次。

const EFFECT_ID = 20337
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_CD = 9

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20337_start():
	var targets = []
	var teammates = get_teammate_targets(me)
	for key in DataManager.skill_cd.keys():
		# 只看战场限定技
		# TODO, 9xxxx 来判断限定技是否准确？不确定
		if DataManager.skill_cd[key] < 90000:
			continue
		var pieces = str(key).split("/")
		var sceneId = int(pieces[0])
		#var effectId = int(pieces[1])
		var targetId = int(pieces[2])
		if not targetId in teammates:
			continue
		if sceneId < 20000 or sceneId >= 30000:
			continue
		targets.append(targetId)
	if not wait_choose_actors(targets, "选择队友发动【{0}】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20337_2():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "对{0}发动【{1}】\n重置其限定技冷却\n可否？".format([
		targetActor.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20337_3():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	ske.cost_war_cd(COST_CD)
	var ret = ske.clear_actor_skill_cd(targetId, [20000], [], 90000, 99999)
	ske.war_report()

	var msg = "战阵相争，非吾所长\n{0}大可放手施为".format([
		DataManager.get_actor_honored_title(targetId, self.actorId),
	])
	me.attach_free_dialog(msg, 1)
	var cleared = []
	for skillName in ret:
		if ret[skillName] > 0:
			msg = "【{0}】的冷却减为 {1}".format([skillName, ret[skillName]])
			me.attach_free_dialog(msg, 1, 20000, targetId)
		else:
			cleared.append("【" + skillName + "】")
	if cleared.size() > 0:
		if cleared.size() > 3:
			cleared[2] += "等{0}个技能".format([cleared.size()])
			cleared = cleared.slice(0, 2)
		msg = "".join(cleared) + "的冷却被清除"
		me.attach_free_dialog(msg, 1, 20000, targetId)
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
