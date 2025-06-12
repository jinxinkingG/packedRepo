extends "effect_20000.gd"

#孤锋锁定技 #免止 #计策减伤
#【孤锋】大战场，锁定技。你方主将之外的队友都在城地形或不存在，你不会被定止，且你在非平地型时，受到计策伤害降为25%。

func on_trigger_20002()->bool:
	if not check_condition():
		return false
	var blockCN = map.get_blockCN_by_position(me.position)
	if blockCN == "平原":
		return false
	change_scheme_damage_rate(-75)
	return false

func on_trigger_20022()->bool:
	if not check_condition():
		return false
	var key = "BUFF.{0}".format([me.actorId])
	if DataManager.get_env_str(key) != "定止":
		return false

	var buff = me.get_buff("定止")
	if buff["回合数"] <= 0:
		return false

	var skillInfo = "【{1}】解除定止".format([
		actor.get_name(), ske.skill_name,
	])
	var msg = "孤锋突进，谁敢拦我！\n（{0}".format([skillInfo])
	var d = me.attach_free_dialog(msg, 0)
	d.callback_script = "effects/20000-war/effect_20000.gd"
	d.callback_method = "freedom"
	var se = DataManager.get_current_stratagem_execution()
	se.skip_redo = 1
	se.append_message(skillInfo)
	return false

# 前提条件：除主将外，所有队友都在城地形
func check_condition()->bool:
	for targetId in get_teammate_targets(me, 999):
		if targetId == me.get_main_actor_id():
			continue
		var wa = DataManager.get_war_actor(targetId)
		if not map.get_blockCN_by_position(wa.position) in StaticManager.CITY_BLOCKS_CN:
			return false
	return true
