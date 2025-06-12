extends "effect_20000.gd"

#感怀主动技 #解锁技能
#【感怀】大战场，主动技。指定一个己方武将，直到本回合结束前，你令其无视等级条件获得其自身未解锁技能。每回合限1次。

const EFFECT_ID = 20540
const FLOW_BASE = "effect_" + str(EFFECT_ID)

# 发动主动技
func effect_20540_start() -> void:
	var targets = []
	for targetId in get_teammate_targets(me):
		if SkillHelper.get_actor_locked_skill_names(targetId).empty():
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有合适的发动对象"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择队友发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

# 已选定队友
func effect_20540_2() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(1)
	for skillName in SkillHelper.get_actor_locked_skill_names(targetId).values():
		ske.add_war_skill(targetId, skillName, 1)
	ske.war_report()

	var msg = "困锁重重，卿何以教我？"
	play_dialog(actorId, msg, 3, 2001)
	return

func on_view_model_2001() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20540_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "臣无他言，唯奋勇以报"
	report_skill_result_message(ske, 2002, msg, 0, targetId, false)
	return

func on_view_model_2002():
	wait_for_pending_message(FLOW_BASE + "_report")
	return

func effect_20540_report():
	report_skill_result_message(ske, 2002)
	return
