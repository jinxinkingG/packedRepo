extends "effect_20000.gd"

# 策行效果
#【策行】大战场，锁定技。你可对距离3及以内的“旋目标”发起攻击宣言；若你获胜，可以强制目标以你为中心位移至对称的空位，该效果每回合限一次。

const ZHOUXUAN_EFFECT_ID = 20574

func on_trigger_20020() -> bool:
	var targetId = ske.get_war_skill_val_int(ZHOUXUAN_EFFECT_ID, actorId, -1)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if not me.is_enemy(target):
		return false
	var bf = DataManager.get_current_battle_fight()
	if bf.loserId != target.actorId:
		return false
	var terrian = map.get_blockCN_by_position(target.position)
	if terrian in StaticManager.CITY_BLOCKS_CN:
		return false
	var pos = me.position * 2 - target.position
	if not target.can_move_to_position(pos):
		return false
	terrian = map.get_blockCN_by_position(pos)
	if terrian in StaticManager.CITY_BLOCKS_CN:
		return false
	var msg = "{0}，合丧于此地！".format([
		DataManager.get_actor_naughty_title(target.actorId, actorId)
	])
	ske.cost_war_cd(1)
	ske.war_report()
	var d = me.attach_free_dialog(msg, 0)
	d.callback_script = "effects/20000-war/effect_20575.gd"
	d.callback_method = "trick"
	return false

func trick() -> bool:
	me = DataManager.get_war_actor(actorId)
	var targetId = SkillHelper.get_skill_variable_int(20000, ZHOUXUAN_EFFECT_ID, actorId, -1)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if not me.is_enemy(target):
		return false
	var msg = "此何地也 ……\n是何手段！"
	var d = me.attach_free_dialog(msg, 0, 20000, target.actorId)
	d.callback_script = "effects/20000-war/effect_20575.gd"
	d.callback_method = "move"
	var pos = me.position * 2 - target.position
	map.show_color_block_by_position([pos])
	map.show_can_choose_actors([target.actorId])
	return false

func move() -> bool:
	me = DataManager.get_war_actor(actorId)
	var targetId = SkillHelper.get_skill_variable_int(20000, ZHOUXUAN_EFFECT_ID, actorId, -1)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if not me.is_enemy(target):
		return false
	var pos = me.position * 2 - target.position
	target.position = pos
	map.show_color_block_by_position([])
	map.clear_can_choose_actors()
	map.draw_actors()
	return false

func on_trigger_20030() -> bool:
	var targetId = ske.get_war_skill_val_int(ZHOUXUAN_EFFECT_ID, actorId, -1)
	if targetId < 0:
		return false
	var target = DataManager.get_war_actor(targetId)
	if not me.is_enemy(target):
		return false
	if Global.get_distance(me.position, target.position) > 3:
		return false
	var extra = DataManager.get_env_int_array("战争.额外攻击目标")
	extra.append(target.actorId)
	DataManager.set_env("战争.额外攻击目标", extra)
	return false

