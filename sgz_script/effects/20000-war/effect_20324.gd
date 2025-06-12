extends "effect_20000.gd"

#教谕主动技实现
#【教谕】大战场,主动技。选择1名己方武将，进入学问馆界面。

const EFFECT_ID = 20324
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const SKILL_NAME = "【教谕】"

func _init() -> void:
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_4", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_choose_actor(FLOW_BASE + "_2", true)
		2001:
			wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20324_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var me = DataManager.get_war_actor(self.actorId)
	var targets = get_teammate_targets(me)
	targets.append(self.actorId)
	if not wait_choose_actors(targets, "选择我方武将发动{0}".format([SKILL_NAME])):
		return
	LoadControl.set_view_model(2000)
	return

func effect_20324_2():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetId = int(DataManager.common_variable["目标"])
	var msg = "学而不战则罔\n战而不学则殆"
	play_dialog(self.actorId, msg, 2, 2001)
	return

func effect_20324_3():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var targetId = int(get_env("目标"))
	DataManager.player_choose_actor = targetId
	DataManager.common_variable["进修.返回"] = FLOW_BASE + "_4"
	FlowManager.add_flow("load_script|affiars/fair_school.gd")
	FlowManager.add_flow("school_2")
	return

func effect_20324_4():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	DataManager.player_choose_actor = self.actorId
	FlowManager.add_flow("player_skill_end_trigger")
	return
