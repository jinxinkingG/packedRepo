extends "effect_30000.gd"

#破围效果实现
#【破围】小战场，锁定技。你攻击前，若你周围1圈内存在X个敌兵，X>0时，你的近战攻击对敌兵造成（120+15X）%的伤害，若X至少为2，则本次攻击计算伤害时，体＜50按50计算。

# 行动决策后根据当前形势决定临时伤害倍率和攻击标签
func on_trigger_30001() -> bool:
	var bu = get_action_unit()
	if bu == null or bu.leaderId != me.actorId:
		return false
	if bu.get_unit_type() != "将":
		return false
	var x = get_enemies_around(bu)
	if x <= 0:
		return false

	bu.append_once_damage_rate(1.2 + min(5, x) * 0.15)
	if x > 1:
		bu.append_once_attack_tag(["破围", "破围☆", "破围★"][min(x - 2, 2)], 1)
	return false

# 在攻击发生后触发，根据当前形势设定近身伤害倍率
func on_trigger_30014()->bool:
	var bu = get_action_unit()
	if bu == null or bu.leaderId != me.actorId:
		return false
	if bu.get_unit_type() != "将":
		return false
	var x = get_enemies_around(bu)
	if x >= 2:
		var hp = get_env_int("白兵.伤害基准体力")
		hp = max(50, hp)
		set_env("白兵.伤害基准体力", hp)
	return false

# 检查身周一圈的敌方单位数
func get_enemies_around(unit:Battle_Unit)->int:
	var enemies_around = 0
	var offsets = StaticManager.NEARBY_DIRECTIONS.duplicate()
	offsets.append_array([
		Vector2(-1, -1),
		Vector2(1, 1),
		Vector2(-1, 1),
		Vector2(1, -1),
	])
	for offset in offsets:
		var pos = unit.unit_position + offset
		var bu = DataManager.get_battle_unit_by_position(pos)
		if bu == null or bu.leaderId == me.actorId or bu.get_unit_type() == "将":
			continue
		enemies_around += 1
	return enemies_around
