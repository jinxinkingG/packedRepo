extends "effect_20000.gd"

# 军正大战场效果 #施加状态
#【军正】大战场&小战场，锁定技。①你被附加 {疲兵} 或 {迟滞} 时，自动解除。②对方使用持续性战术时，持续回合数-1。

func on_trigger_20022() -> bool:
	var key = "BUFF.{0}".format([actorId])
	var buffName = DataManager.get_env_str(key)
	if not buffName in ["疲兵", "迟滞"]:
		return false

	var buff = me.get_buff(buffName)
	if buff["回合数"] <= 0:
		return false

	var msg = "进退合度，谁能乱我军阵！\n（【{0}】免于{1}".format([ske.skill_name, buffName])
	var d = me.attach_free_dialog(msg, 0)
	d.callback_script = "effects/20000-war/effect_20630.gd"
	d.callback_method = "clearance"
	ske.append_message("免疫" + buffName)
	ske.war_report()
	return false

func clearance() -> bool:
	var me = DataManager.get_war_actor(actorId)
	me.set_buff("疲兵", 0, -1, "", true)
	me.set_buff("迟滞", 0, -1, "", true)
	map.draw_actors()
	return false
