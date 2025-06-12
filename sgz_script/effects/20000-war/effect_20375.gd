extends "effect_20000.gd"

#替援主动技 #营帐
#【替援】大战场，主将主动技。你选择营帐里一个武将，再选择一个己方武将，直接交换两者，营帐武将继承已出阵武将的机动力。每个回合限1次。

const EFFECT_ID = 20375
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func check_AI_perform_20000()->bool:
	# 可用目标
	var candidate = -1
	for targetId in get_camp_targets(me):
		if ActorHelper.actor(targetId).get_soldiers() >= 1000:
			candidate = targetId
			break
	if candidate < 0:
		return false
	# 值得替换的对象
	for targetId in get_teammate_targets(me):
		if ActorHelper.actor(targetId).get_soldiers() < 400:
			return true
	return false

func effect_20375_AI_start():
	# 找队友里兵最少的
	var sentinel = 9999
	var targetId = -1
	for id in get_teammate_targets(me):
		var soldiers = ActorHelper.actor(id).get_soldiers()
		if soldiers < sentinel:
			sentinel = soldiers
			targetId = id
	# 找营帐里兵最多的
	var withId = -1
	sentinel = 0
	for id in get_camp_targets(me):
		var soldiers = ActorHelper.actor(id).get_soldiers()
		if soldiers > sentinel:
			sentinel = soldiers
			withId = id
	# 经过 check_AI_perform 的判断
	# 已经确保有合理的发动对象了
	# 所以这里不判断 targetId/withId -1 的情况
	set_env("战争.替援.目标", targetId)
	set_env("目标项", withId)
	goto_step("3")
	return

func effect_20375_start():
	var wv = me.war_vstate()
	if wv == null or wv.camp_actors.empty():
		var msg = "营帐中暂无可替换的武将"
		play_dialog(me.actorId, msg, 3, 2999)
		return
	if not wait_choose_actors(get_teammate_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20375_2():
	var targetId = DataManager.get_env_int("目标")
	DataManager.set_env("战争.替援.目标", targetId)
	var targetActor = ActorHelper.actor(targetId)
	var targets = [null]
	for campedId in get_camp_targets(me):
		var campActor = ActorHelper.actor(campedId)
		var soldiers = campActor.get_soldiers()
		for i in targets.size():
			if targets[i] != null and targets[i].get_soldiers() > soldiers:
				continue
			targets.insert(i, campActor)
			break
		if targets.size() >= 9:
			break
	targets.erase(null)
	if targets.empty():
		var msg = "营帐中暂无可替换的武将"
		play_dialog(me.actorId, msg, 3, 2999)
		return
	var items = []
	var values = []
	for target in targets:
		var name = target.get_name()
		var spaces = "　".repeat(max(1, 6 - name.length()))
		items.append("{0}{1}兵力：{2}".format([
			name, spaces, target.get_soldiers()
		]))
		values.append(target.actorId)
	var msg = "请选择替换{0}出阵的武将".format([targetActor.get_name()])
	SceneManager.show_unconfirm_dialog(msg, me.actorId)
	bind_menu_items(items, values, 1)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_item(FLOW_BASE + "_3")
	return

func effect_20375_3():
	var wv = me.war_vstate()
	var targetId = get_env_int("战争.替援.目标")
	var withId = get_env_int("目标项")
	set_env("战争.替援.替补", withId)
	var target = DataManager.get_war_actor(targetId)
	var ap = target.action_point
	var pos = target.position
	
	ske.cost_war_cd(1)
	ske.war_camp_in(targetId)
	ske.war_camp_out(withId)
	var with = DataManager.get_war_actor(withId)
	with.action_point = 0
	ske.change_actor_ap(withId, ap)
	ske.change_war_actor_position(withId, pos)
	ske.war_report()

	var msg = "{0}久战恐有不利\n还请{1}速往援助".format([
		ActorHelper.actor(targetId).get_name(),
		ActorHelper.actor(withId).get_name(),
	])
	play_dialog(me.actorId, msg, 2, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20375_4():
	var withId = get_env_int("战争.替援.替补")
	var msg = "诺！此阵{0}当之\n必可无忧".format([
		DataManager.get_actor_self_title(withId),
	])
	play_dialog(withId, msg, 0, 2999)
	return
