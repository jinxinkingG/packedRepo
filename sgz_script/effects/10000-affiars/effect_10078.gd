extends "effect_10000.gd"

#弼国锁定技
#【弼国】内政，锁定技。你进行情报搜集时，可消耗20点体力值，手动选择搜集结果。每月限1次。

const EFFECT_ID = 10078
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_HP = 20

func on_trigger_10017()->bool:
	var cmd = DataManager.get_current_search_command()
	if cmd == null:
		return false
	return actor.get_hp() > 20

func effect_10078_start():
	var msg = "消耗{0}体发动【{1}】\n可否？".format([
		COST_HP, ske.skill_name,
	])
	SceneManager.show_yn_dialog(msg, actorId, 2)
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000():
	wait_for_yesno(FLOW_BASE + "_2", FLOW_BASE + "_end")
	return

func effect_10078_2():
	ske.affair_cd(1)
	actor.set_hp(actor.get_hp() - 20)
	var msg = "搜索何物？"
	var items = ["金", "米", "宝物", "人才"]
	var vals = [3, 2, 4, 5]
	bind_bottom_menu(items, vals, msg, 2)
	LoadControl.set_view_model(2001)
	return

func on_view_model_2001():
	wait_for_choose_menu_item(FLOW_BASE + "_3")
	return

func effect_10078_3():
	var cmd = DataManager.get_current_search_command()
	cmd.result = DataManager.get_env_int("目标项")
	goto_step("end")
	return

func effect_10078_end():
	LoadControl.end_script()
	return
