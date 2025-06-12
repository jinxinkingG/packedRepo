extends "effect_20000.gd"

#急功主动技 #解除状态
#【急功】大战场,限定技。发动后：你立刻解除定止，并进入移动模式，体＞10时，可以此法进行的移动不消耗机动力，每步消耗5体力，可随时退出本移动状态。

const EFFECT_ID = 20189
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const MIN_HP = 10

func _init():
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_3", self)
	return

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_yesno(FLOW_BASE + "_2", true)
		2001:
			wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

# 发动主动技
func effect_20189_start():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.actorId
	var me = DataManager.get_war_actor(self.actorId)

	if not assert_min_hp(self.actorId, MIN_HP):
		return

	var msg = "发动【急功】进入移动模式\n不消耗机动力\n每一步减5体，可否？"
	play_dialog(self.actorId, msg, 2, 2000, true)
	return

func effect_20189_2():
	var ske = SkillHelper.read_skill_effectinfo()
	var msg = "今利在急战\n不可落人后\n全军轻装速进！"
	play_dialog(ske.skill_actorId, msg, 2, 2001)
	return

func effect_20189_3():
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.actorId
	var me = DataManager.get_war_actor(self.actorId)
	var war_map = SceneManager.current_scene().war_map

	ske.cost_war_cd(99999)
	ske.remove_war_buff(ske.skill_actorId, "定止")
	# 仅记录日志
	ske.war_report()
	SkillHelper.set_skill_variable(20000, EFFECT_ID, self.actorId, 1, 99999)
	LoadControl.end_script()
	FlowManager.add_flow("load_script|war/player_move.gd");
	FlowManager.add_flow("actor_move_start");
	return
