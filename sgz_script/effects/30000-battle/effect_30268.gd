extends "effect_30000.gd"

#双骑锁定技
#【双骑】小战场，锁定技。你方存在其他拥有<双骑>技能的武将时，在你的身旁创造一个“将”类单位（该单位的攻击/防御/初始血量均按照那名队友计算）。

func on_trigger_30005() -> bool:
	var bro = null
	for teammate in me.war_vstate().get_war_actors(false, true):
		if teammate.actorId == actorId:
			continue
		if SkillHelper.actor_has_skills(teammate.actorId, ["双骑"], false):
			bro = teammate
			break
	if bro == null:
		return false
	var bf = DataManager.get_current_battle_fight()

	var unit = me.battle_actor_unit()
	var bu = Battle_Unit.new()
	bu.unitId = DataManager.battle_units.size()
	bu.leaderId = actorId
	bu.direction = unit.direction
	bu._private_hp = bro.actor().get_hp()
	bu.disabled = false
	bu.init_combat_info("骑(化身)")
	bu.unit_position = unit.unit_position + Vector2.UP
	bu.dic_other_variable["临时"] = 1
	bu.wait_action_times = bu.get_action_times()
	bu.requires_update = true
	DataManager.battle_units.append(bu)
	SceneManager.current_scene().create_or_update_unit(bu)

	var msg = "吾兄弟共讨{0}！"
	if actorId == bf.get_defender_id():
		msg = "吾兄弟共拒{0}！"
	msg = msg.format([DataManager.get_actor_naughty_title(enemy.actorId, bro.actorId)])
	me.attach_free_dialog(msg, 0, 30000, bro.actorId)
	return false
