extends "effect_10000.gd"

#躬亲主动技
#【躬亲】内政，主动技。使用后，消耗 20 体，+1 命令书，每月限一次

const EFFECT_ID = 10012
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_10012_start():
	if actor.get_hp() < 21:
		SceneManager.show_confirm_dialog("病体难以久支，尚需休养…", actorId, 3)
		LoadControl.set_view_model(2001)
		return
	SceneManager.show_cityInfo(false)
	SceneManager.show_confirm_dialog("王业待兴，何待惜身？", actorId)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_10012_2():
	SceneManager.hide_all_tool()
	ske.affair_cd(1)
	actor.set_hp(max(1, actor.get_hp() - 20))
	DataManager.orderbook += 1
	SceneManager.actor_dialog.conOrderbook.update_orderbook()
	var msg = "命令书 +1\n{0}体力降为{1}".format([
		actor.get_name(), int(actor.get_hp()),
	])
	SceneManager.show_confirm_dialog(msg)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_skill_result_confirmation()
	return
