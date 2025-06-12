extends "effect_30000.gd"

#拔矢效果实现
#【拔矢】小战场，锁定技。你被箭矢击中后，本回合你的行动提前，立即强制前进状态行动6次（该行动，可无视定止），行动完立即回到行动前的位置，每次小战场限一次。

func on_trigger_30011()->bool:
	var bu = ske.battle_is_unit_hit_by(["弓", "将"], ["将"], ["ALL"], true)
	if bu == null:
		return false
	var hurt = get_leader_unit(me.actorId)
	if hurt == null or hurt.disabled:
		return false

	if actor._get_attr_str("啖睛") != "1":
		actor._set_attr_str("啖睛", "1")
		var msg = "受之父母，不可弃也！\n（{0}啖睛暴走".format([me.get_name()])
		append_free_dialog(me, msg, 0)
	ske.battle_cd(99999)
	var bia = Battle_Instant_Action.new()
	bia.unitId = hurt.unitId
	bia.action = "暴走"
	bia.targetUnitId = bu.unitId
	bia.targetPos = bu.unit_position
	bia.actionTimes = 6
	bia.insert_to_env()
	hurt.add_status_effect("暴走#FF0000")
	return false
