extends "effect_20000.gd"

#警叛诱发技
#【警叛】大战场，诱发技。你方武将被笼络成功时，你可以发动：选择一个己方武将与背叛者进入白刃战，且己方武将的士气+10，战术值+10

const EFFECT_ID = 20326
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_4", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)
	return

func _input_key(delta:float):
	var view_model = LoadControl.get_view_model();
	match view_model:
		2000:
			wait_for_choose_actor(FLOW_BASE + "_2", false)
		2001:
			wait_for_yesno(FLOW_BASE + "_3", false)
		2002:
			wait_for_skill_result_confirmation(FLOW_BASE + "_4")
	return

func effect_20326_AI_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	set_env("目标", self.actorId)
	FlowManager.add_flow(FLOW_BASE + "_3")
	return

func effect_20326_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetId = get_env_int("技能.警判.目标")
	var me = DataManager.get_war_actor(self.actorId)
	var targets = get_teammate_targets(me)
	targets.append(self.actorId)
	if not wait_choose_actors(targets, "选择己方武将发动【警判】"):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20326_2():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var fromId = int(get_env("目标"))
	var targetId = get_env_int("技能.警判.目标")
	var msg = "发动【警判】\n令{0}攻击{1}\n可否？"
	if fromId == self.actorId:
		msg = "发动【警判】\n攻击{1}\n可否？"
	msg = msg.format([
		ActorHelper.actor(fromId).get_name(),
		ActorHelper.actor(targetId).get_name()
	])
	play_dialog(self.actorId, msg, 2, 2001, true)
	return

func effect_20326_3():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var fromId = get_env_int("目标")
	set_env("技能.警判.武将", fromId)
	var targetId = get_env_int("技能.警判.目标")
	var msg = "可恨{0}！反复无常！".format([
		DataManager.get_actor_naughty_title(targetId, self.actorId),
	])
	if fromId == self.actorId:
		msg += "\n待吾自讨之！"
	else:
		msg += "\n烦请{0}讨之！".format([
			DataManager.get_actor_honored_title(fromId, self.actorId)
		])
	play_dialog(self.actorId, msg, 0, 2002)
	return

func effect_20326_4():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var fromId = get_env_int("技能.警判.武将")
	var targetId = get_env_int("技能.警判.目标")
	unset_env("技能.警判.武将")
	unset_env("技能.警判.目标")
	inc_skill_triggered_times(fromId, EFFECT_ID, 20000)
	start_battle_and_finish(fromId, targetId)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var se = DataManager.get_current_stratagem_execution()
	if se.get_action_id(self.actorId) != ske.actorId:
		return false
	if se.name != "笼络":
		return false
	if se.succeeded <= 0:
		return false
	se.report()
	set_env("技能.警判.目标", se.targetId)
	return true
