extends "effect_20000.gd"

#私掠主动技
#【私掠】大战场，锁定技。战争开始，你选择1名双方场上除自己之外的任意1名武将获得“私掠”标记。“私掠”武将「白刃战败」或「被用伤兵计损兵」的场合，你可获得其1半机动力。每回合仅触发1次。

const EFFECT_ID = 20454
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20019()->bool:
	var wf = DataManager.get_current_war_fight()
	if wf.date != 1:
		return false
	ske.cost_war_cd(999)
	return true

# 目前 AI 不能发动，会有卡死问题
func effect_20454_AI_start_disabled()->void:
	var targets = get_enemy_targets(me, true, 999)
	var score = 1000
	var selected = -1
	for targetId in targets:
		var targetActor = ActorHelper.actor(targetId)
		var wisdom = targetActor.get_wisdom()
		if wisdom < score:
			score == wisdom
			selected = targetId
	if selected < 0:
		skill_end_clear(true)
		return
	DataManager.set_env("目标", selected)
	goto_step("2")
	return

func effect_20454_start()->void:
	var targets = get_enemy_targets(me, true, 999)
	targets.append_array(get_teammate_targets(me, 999))
	if not wait_choose_actors(targets, "选择【{0}】对象", true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2", false, false)
	return

func effect_20454_2()->void:
	var targetId = DataManager.get_env_int("目标")
	ske.set_war_skill_val(targetId, 99999)
	var msg = "将{0}设定为【{1}】目标".format([
		ActorHelper.actor(targetId).get_name(), ske.skill_name
	])
	play_dialog(actorId, msg, 0, 2999)
	return

func on_view_model_2999():
	wait_for_skill_result_confirmation("")
	return
