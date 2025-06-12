extends "effect_30000.gd"

#援召锁定技
#【援召】小战场，锁定技。若你不是城门或太守府守方，且兵力小于500，则进入白刃战时，临时增加1个骑兵单位，兵力100，战后消失。

const YUANZHAO_HP = 100

func on_trigger_30005()->bool:
	if me == null:
		return false
	if me.get_soldiers() >= 500:
		return false
	var unit = me.battle_actor_unit()
	if unit == null:
		return false

	var bu = Battle_Unit.new()
	bu.unitId = DataManager.battle_units.size()
	bu.leaderId = actorId
	bu.direction = unit.direction
	bu._private_hp = YUANZHAO_HP
	bu.disabled = false
	bu.init_combat_info()
	bu.unit_position = Vector2(-1, -1)
	bu.init_combat_info("骑")
	bu.wait_action_times = bu.get_action_times()
	bu.dic_other_variable["临时"] = 1
	DataManager.battle_units.append(bu)
	# 重新调用整体布阵，加入新增的单位
	var bf = DataManager.get_current_battle_fight()
	var formation = bf.attacker_formation
	if actorId == bf.get_defender_id():
		formation = bf.defender_formation
	bf.set_formation(actorId, formation)

	SceneManager.current_scene().create_or_update_unit(bu)
	return false
