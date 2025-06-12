extends "effect_20000.gd"

#叫阵诱发技
#【叫阵】大战场，诱发技。战争开始时，你可选择对方一个非主将的武将进入白刃战，并且交战地形固定为平地。若对方也存在拥有该技能的将领，则你只能从那些将领中选择目标。

const EFFECT_ID = 20442
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20028()->bool:
	var wf = DataManager.get_current_war_fight()
	# 仅第一天允许发动
	if wf == null or wf.date != 1:
		return false
	if get_proper_targets().empty():
		return false
	if ske.get_war_skill_val_int() > 0:
		return false
	# 可发动，则无论发动与否，设置标记，避免重复触发
	ske.set_war_skill_val(1)
	return true

func effect_20442_AI_start():
	var targets = get_proper_targets()
	var selectedId = -1
	# 模拟计算，对比战斗力，找最弱的对手
	me.battle_init(true)
	var leastScore = me.battle_morale * me.get_soldiers() * 0.8
	for targetId in targets:
		var wa = DataManager.get_war_actor(targetId)
		wa.battle_init(true)
		var score = wa.battle_morale * wa.get_soldiers()
		if score < leastScore:
			leastScore = score
			selectedId = targetId
	if selectedId < 0:
		skill_end_clear()
		return
	DataManager.set_env("目标", selectedId)
	goto_step("3")
	return

func effect_20442_start():
	var targets = get_proper_targets()
	if not wait_choose_actors(targets, "选择对手发动【{0}】", true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2", false)
	return

func effect_20442_2():
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "对{0}发动【{1}】\n可否？".format([
		targetActor.get_name(), ske.skill_name
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3", false)
	return

func effect_20442_3():
	ske.cost_war_cd(99999)
	var targetId = DataManager.get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)
	var msg = "{0}徒有凶名\n可敢与我一战！"
	if targetActor.get_power() < actor.get_power():
		msg = "{0}手无缚鸡之力\n也敢堂堂列阵！"
		if targetActor.get_courage() < actor.get_courage():
			msg = "{0}每战龟缩不前\n今日哪里逃！"
	msg = msg.format([
		DataManager.get_actor_naughty_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 0, 2002)
	return

func on_view_model_2002():
	wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20442_4():
	var targetId = DataManager.get_env_int("目标")
	start_battle_and_finish(actorId, targetId, ske.skill_name, actorId, "land")
	return

func get_proper_targets()->PoolIntArray:
	var targets = get_enemy_targets(me, true, 999)
	var enemyLeader = me.get_war_enemy_leader()
	if enemyLeader != null:
		targets.erase(enemyLeader.actorId)
	if targets.empty():
		return targets
	var priorTargets = []
	for targetId in targets:
		if SkillHelper.actor_has_skills(targetId, [ske.skill_name]):
			priorTargets.append(targetId)
	if priorTargets.empty():
		return targets
	return priorTargets
