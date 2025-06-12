extends Resource

#伤害计算相关
func _init() -> void:
	return

#经典算法
func count_classic_damage(from:Battle_Unit, to:Battle_Unit)->float:
	var bf = DataManager.get_current_battle_fight()
	#基础攻击力
	var baseAttack = 0
	#最终攻击力
	var attack = 0

	var lastAction = from.last_action_name.split("|")[0]
	var isShooting = lastAction == "射箭"
	var isThrowing = lastAction == "投掷"

	var attacker = from.leader()
	var defender = to.leader()
	var defenderLeadership = 0
	if defender != null:
		defenderLeadership = defender.battle_lead

	# 计算基础攻击力
	match from.get_unit_type():
		"将":#武将.基础攻击力=武*胆%*0.7+装备攻击力
			baseAttack = attacker.get_battle_power() * attacker.battle_courage / 100.0 * 0.7
			baseAttack += from.actor().get_equip_attr_total("攻击力")
			baseAttack += from.actor().get_equip_feature_total("白兵攻击力")
			baseAttack += from.get_extra_attack_power()
		_:#士兵.基础攻击力=士气
			baseAttack = attacker.battle_morale

	# 士气向上，提升基础攻击力
	if attacker.get_buff("士气向上")["回合数"] > 0:
		baseAttack += Global.get_random(5, 9)

	# 预先计算C值，注意这个要在计算倍率之前
	# 目前【破围】利用了计算 C 值时的回调，修改攻击倍率
	# 这个不太合理，但能用，顺序不能颠倒
	# FIXME later
	var C = get_attack_C_val(from)
	
	# 判断火矢战术和火矢标记
	# 注意战术对所有攻击有效
	# 除战术外的火矢标记只对射击有效
	var fireShooting = false
	if isShooting:
		fireShooting = from.is_fire_shooting([to])
		from.cost_fire_shot()
	else:
		fireShooting = attacker.get_buff("火矢")["回合数"] > 0

	#实际攻击力=基础攻击力*近\远程倍率
	if isShooting:
		#火矢，提升箭类基础攻击力
		if fireShooting:
			baseAttack += Global.get_random(9, 15)
		var rate = from.get_shooting_damage_rate(to)
		#双方距离
		var distance = Global.get_distance(from.unit_position, to.unit_position)
		#判断万石弓效果（倍率+距离*0.1）
		if from.get_unit_type() == "将":
			var distanceRate = from.actor().get_equip_feature_total("距离增加倍率")
			if distanceRate > 0:
				rate += float(distance * distanceRate / 100.0)
		if distance > 4 && DataManager.diffculities >= 3 && bf.get_terrian() in ["wallcity"]:
			if from.get_side() == Vector2.RIGHT:
				rate /= 2
		attack = baseAttack * rate
	elif isThrowing:
		var rate = from.get_throwing_damage_rate(to)
		attack = baseAttack * rate
	else:
		var rate = from.get_melee_damage_rate()
		if DataManager.diffculities>=3 && bf.get_terrian() in ["wallcity","walldoor"]:
			if from.get_side() == Vector2.RIGHT:
				rate = max(rate, 1.0)
		attack = baseAttack * rate

	# 基本伤害 = 实际攻击力*C/100.0
	var damage:float = attack * C / 100.0

	# 考虑暴击，在此前的 attack action 中检查过了
	# 直接采信结果
	# 此时是伤害结算，在这里计算不合适，无法配合视效
	damage = damage * from.get_critical_damage_rate()

	# 防御力
	var E:float = 0.0
	if to.get_unit_type() == "将":
		E = to.actor().get_equip_attr_total("防御力")
		E += defender.battle_courage / 8.0
		E = E / 2.0
	else:
		E = defenderLeadership / 12.0
	if to.dic_combat.has("防御倍率"):
		E = E * float(to.dic_combat["防御倍率"])
	if defender.get_buff("士气向上")["回合数"] > 0:
		#士气向上，防御力提升20%
		E = E * 1.2;
		
	if isShooting and to.get_unit_type() != "将":
		#火矢，无视目标1/3防御力
		if fireShooting:
			E -= E / 3.0

	# 免伤比例 = 兵种类型免伤 + 装备免伤加成
	var avoidRate = to.get_damage_avoid_rate()
	#计算受击方免伤=基本伤害*免伤比例+装备防御力
	var avoidDamage = min(damage * avoidRate + E, damage)
	
	#实际伤害=基本伤害-免伤
	var finalDamage:float = damage - avoidDamage
	finalDamage = finalDamage * from.get_once_damage_rate()
	
	if to.get_unit_type() == "将":
		var minDamage = 0.5
		if DataManager.diffculities >= 3:
			minDamage = 1
		finalDamage = max(minDamage, finalDamage)
		# 武将被打，伤害至多12点
		finalDamage = min(finalDamage, 12)
	else:
		# 士兵被打，最低伤害由 5 调整为 10 - [统/10]
		var minDamage = 10
		minDamage -= int(defenderLeadership / 10)
		minDamage = max(1, minDamage)
		finalDamage = max(minDamage, finalDamage)
		finalDamage = max(finalDamage, minDamage)
		# 士兵伤害尽量为整数
		finalDamage = int(finalDamage)

	return finalDamage

# 根据体力计算攻击C值
func get_attack_C_val(attack_unit:Battle_Unit):
	#	C是根据血量计算出的参数
	#	血量在不同区间内的不同C值：
	#	当体∈[0,15),C=20
	#	当体∈[15,35),C=40
	#	当体∈[35,60),C=50
	#	当体∈[60,80),C=70
	#	当体∈[80,90),C=85
	#	当体∈[90,100),C=95
	#	当体∈[100,∞),C=100

	var hp:float = attack_unit.get_hp()
	
	DataManager.set_env("白兵.伤害基准体力", hp)
	SkillHelper.auto_trigger_skill(attack_unit.leaderId, 30014, "")
	hp = DataManager.get_env_float("白兵.伤害基准体力")
	if attack_unit.get_unit_type() == "将":
		if attack_unit.actor().get_equip_feature_max("白刃C按满体") > 0:
			#贯石斧特效，按满体计算C值
			hp = max(hp, attack_unit.actor().get_max_hp())
		hp = hp * 2
	var C = 100
	var limits = [15, 35, 60, 80, 90, 100]
	var values = [20, 40, 50, 70, 85, 95]
	for i in limits.size():
		if hp < limits[i]:
			C = values[i]
			break
	return C
