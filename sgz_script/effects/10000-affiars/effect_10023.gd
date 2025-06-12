extends "effect_10000.gd"

#金猪效果
#【金猪】内政,主动技。你可以将永久标记[金]转化为经验，1个永久标记[金]＝1经验

const EFFECT_ID = 10023
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init() -> void:
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_2", self)
	return

func _input_key(delta:float):
	var view_model = LoadControl.get_view_model();
	match view_model:
		2000:
			wait_for_skill_result_confirmation(FLOW_BASE + "_2")
		2001:
			wait_for_skill_result_confirmation("player_ready")
	return

func effect_10023_start():
	LoadControl.set_view_model(121)
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var x = SkillHelper.get_skill_flags_number(10000, EFFECT_ID, self.actorId, "金")
	if x <= 0:
		LoadControl.set_view_model(2001)
		SceneManager.show_confirm_dialog("敛财不足，得抓紧了...", self.actorId, 3)
		return

	var actor = ActorHelper.actor(self.actorId)
	if actor.is_exp_full():
		LoadControl.set_view_model(2001)
		SceneManager.show_confirm_dialog("经验已满，不可浪费...", self.actorId, 1)
		return

	var expToGo:int = ActorHelper.ActorInfo.EXP_MAX - actor.get_exp()
	expToGo = min(expToGo, x)
	x = x - expToGo
	SkillHelper.set_skill_flags(10000, EFFECT_ID, self.actorId, "金", x)
	actor.add_exp(expToGo)
	LoadControl.set_view_model(2000)
	SceneManager.show_cityInfo(false)
	SceneManager.show_confirm_dialog("取之于民，用之于本将", self.actorId, 1)
	return

func effect_10023_2():
	SceneManager.hide_all_tool()
	SceneManager.show_cityInfo(true)
	SceneManager.lsc_menu.show_orderbook(true);
	var ske = SkillHelper.read_skill_effectinfo()
	self.actorId = ske.skill_actorId
	var actor = ActorHelper.actor(self.actorId)
	var x = SkillHelper.get_skill_flags_number(10000, EFFECT_ID, self.actorId, "金")
	var msgs = []
	msgs.append("{0}的 [金] 现为 {1}".format([actor.get_name(), x]))
	msgs.append("经验现为 {0}".format([actor.get_exp()]))
	SceneManager.show_confirm_dialog("\n".join(msgs))
	LoadControl.set_view_model(2001)
	return
