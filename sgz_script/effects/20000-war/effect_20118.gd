extends "effect_20000.gd"

#免止
#蛮裔
#【蛮裔】大战场,锁定技。你受蛮神庇佑，无法被附加“定止”状态。

func on_trigger_20022()->bool:
	var key = "BUFF.{0}".format([actorId])
	if DataManager.get_env_str(key) != "定止":
		return false

	var buff = me.get_buff("定止")
	if buff["回合数"] <= 0:
		return false

	var msg = "蛮神庇佑，来去自如！\n（【{0}】免于定止".format([ske.skill_name])
	var d = me.attach_free_dialog(msg, 0)
	d.callback_script = "effects/20000-war/effect_20000.gd"
	d.callback_method = "freedom"
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1
	ske.append_message("免疫定止")
	ske.war_report()
	return false

