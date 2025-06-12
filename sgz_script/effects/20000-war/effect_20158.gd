extends "effect_20000.gd"

#山守、河守、林守效果实现 #免止 #减伤
#【山守】大战场,锁定技。你在山地形时，不会被定止，受到计策伤害（损兵或损体）减半。
#【河守】大战场,锁定技。你在水地形时，不会被定止，受到计策伤害（损兵或损体）减半。
#【林守】大战场,锁定技。你在林地形时，不会被定止，受到计策伤害（损兵或损体）减半。

func on_trigger_20002()->bool:
	change_scheme_damage_rate(-50)
	return false

func on_trigger_20022()->bool:
	var key = "BUFF.{0}".format([self.actorId])
	if get_env_str(key) != "定止":
		return false
	var buff = me.get_buff("定止")
	if buff["回合数"] <= 0:
		return false

	var skillInfo = "【{0}】解除定止".format([
		ske.skill_name,
	])
	var d = War_Character.DialogInfo.new()
	d.actorId = me.actorId
	d.text = "此地险要，我已悉知\n（{0}".format([skillInfo])
	d.mood = 0
	d.callback_script = "effects/20000-war/effect_20000.gd"
	d.callback_method = "freedom"
	me.add_dialog_info(d)
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1
	se.append_message(skillInfo)
	return false

func on_trigger_20025()->bool:
	change_scheme_hp_damage_rate(self.actorId, ske.skill_name, -50)
	return false
