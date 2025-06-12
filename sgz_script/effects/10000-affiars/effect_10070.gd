extends "effect_10000.gd"

#亢节锁定技
#【亢节】内政，锁定技。你被赏赐的场合，本月结束命令时，你被赏赐的金和宝物，自动回到所在城中。

const EFFECT_ID = 10070
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_10012()->bool:
	if DataManager.get_env_str("内政.命令") != "赏赐武将":
		return false
	var award = DataManager.get_env_str("赏赐物")
	if award == "":
		return false
	var awarded = _get_awarded()
	awarded.append(award)
	ske.affair_set_skill_val(",".join(awarded), 1)
	return false

func on_trigger_10099()->bool:
	var awarded = _get_awarded()
	return awarded.size() > 0

func effect_10070_start():
	var cityId = get_working_city_id()
	if cityId < 0:
		LoadControl.end_script()
		return
	var awarded = _get_awarded()
	if awarded.empty():
		LoadControl.end_script()
		return
	var msg = "{0}蒙恩全活，为幸多矣\n纵国为某，能无愧乎？\n愿拜还所赐".format([
		DataManager.get_actor_self_title(actorId)
	])
	SceneManager.show_confirm_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10070_2():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var awarded = _get_awarded()
	ske.affair_set_skill_val("", 0)
	var gold = 0
	var treasure = 0
	for award in awarded:
		var pieces = award.split("|")
		if pieces.size() != 2:
			continue
		match pieces[0]:
			"金":
				gold += int(pieces[1])
			"宝":
				treasure += int(pieces[1])
	var msgs = []
	msgs.append("{0}退还赏赐".format([ActorHelper.actor(self.actorId).get_name()]))
	if gold > 0:
		city.add_gold(gold)
		msgs.append("{0}金增加{1}".format([
			city.get_name(), gold
		]))
	if treasure > 0:
		city.add_treasures(treasure)
		var msg = "{0}宝物增加{1}"
		if gold > 0:
			msg = "宝物增加{1}"
		msgs.append(msg.format([
			city.get_name(), treasure
		]))
	set_env("对话", "\n".join(msgs))
	FlowManager.add_flow(FLOW_BASE + "_3")
	return

func effect_10070_3():
	var cityId = get_working_city_id()
	var city = clCity.city(cityId)
	var msg = DataManager.get_env_str("对话")
	SceneManager.show_confirm_dialog(msg, city.get_leader_id(), 2)
	SceneManager.show_cityInfo(true, city.ID)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation("")
	return

func _get_awarded()->PoolStringArray:
	var ret = []
	for piece in ske.affair_get_skill_val_str().split(","):
		piece = piece.strip_edges()
		if piece == "":
			continue
		ret.append(piece)
	return ret
