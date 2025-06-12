extends "effect_20000.gd"

#增矛主动技 #解锁技能
#【增矛】大战场,主动技。你可以消耗20[备]，指定一个你方武将，直到下回合之前，该武将获得隐藏技能<长矛>。每回合你至多发动3次，同一个对象不可叠加多次。

const EFFECT_ID = 20250
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const FLAG_NAME = "备"
const FLAG_SCENE_ID = 10000
const FLAG_ID = 10025

const FLAG_COST = 20

const TARGET_SKILL = "长矛"

func on_view_model_2000():
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func on_view_model_2001():
	wait_for_yesno(FLOW_BASE + "_3")
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_4")
	return

# 发动主动技
func effect_20250_start():
	if not assert_flag_count(me.actorId, FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, FLAG_COST):
		return

	var buffed = _get_buffed_actors()
	if buffed.size() >= 3:
		var msg = "【{0}】每日限三次".format([ske.skill_name])
		LoadControl._error(msg, me.actorId)
		return

	var targets = []
	for targetId in get_teammate_targets(me):
		if targetId in buffed:
			continue
		targets.append(targetId)
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

# 已选定队友
func effect_20250_2():
	var targetId = get_env_int("目标")
	var targetActor = ActorHelper.actor(targetId)

	var msg = "消耗{0}[{1}]发动【{3}】\n增强{2}的白兵攻击范围，可否？".format([
		FLAG_COST, FLAG_NAME, targetActor.get_name(), ske.skill_name,
	])
	play_dialog(me.actorId, msg, 2, 2001, true)
	return

func effect_20250_3():
	var targetId = get_env_int("目标")

	if _set_buffed_actor(targetId):
		ske.add_war_skill(targetId, TARGET_SKILL, 2)
	ske.cost_skill_flags(FLAG_SCENE_ID, FLAG_ID, FLAG_NAME, FLAG_COST)

	var msg = "得{0}之助，如虎添翼！\n必破敌以报".format([
		DataManager.get_actor_honored_title(me.actorId, targetId),
	])
	report_skill_result_message(ske, 2002, msg, 0, targetId)
	return

func effect_20250_4():
	report_skill_result_message(ske, 2002)
	return

func _get_buffed_actors()->PoolIntArray:
	var ret = []
	for id in ske.get_war_skill_val_int_array():
		for dic in SkillHelper.get_actor_scene_skills(id):
			if dic["skill_name"] == TARGET_SKILL:
				ret.append(id)
				break
	return ret

func _set_buffed_actor(targetId:int)->bool:
	var buffed = _get_buffed_actors()
	if buffed.size() >= 3:
		return false
	if targetId in buffed:
		return false
	buffed.append(targetId)
	ske.set_war_skill_val(buffed, 1)
	return true
