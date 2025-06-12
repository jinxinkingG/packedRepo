extends "effect_30000.gd"

#接力技能实现
#【接力】小战场,锁定技。每个回合你的同一兵种对同一敌方单位造成的伤害递增百分之10。

const EFFECT_ID = 30056

func check_trigger_correct():
	if not check_env(["白兵伤害.单位", "白兵伤害.伤害", "白兵伤害.来源"]):
		return false

	var att_id = get_env_int("白兵伤害.来源")
	var att_unit = get_battle_unit(att_id)
	if att_unit == null or att_unit.leaderId != self.actorId:
		return false
	if att_unit.get_unit_type() == "将":
		return false

	var def_id = get_env_int("白兵伤害.单位")
	var def_unit = get_battle_unit(def_id)
	if def_unit == null or def_unit.leaderId == self.actorId:
		return false

	# 受击单位字典
	var hitCounters:Dictionary = {}
	var skv = SkillHelper.get_skill_variable(30000, EFFECT_ID, self.actorId)
	if skv["turn"] > 0 and skv["value"] != null:
		hitCounters = parse_json(str(skv["value"]))

	if not hitCounters.has(str(def_id)):
		hitCounters[str(def_id)] = {}
	if not hitCounters[str(def_id)].has(att_unit.get_unit_type()):
		hitCounters[str(def_id)][att_unit.get_unit_type()] = 1
	else:
		hitCounters[str(def_id)][att_unit.get_unit_type()] += 0.1

	# 更新字典，每回合有效
	SkillHelper.set_skill_variable(30000, EFFECT_ID, self.actorId, to_json(hitCounters), 1)
	var rate = hitCounters[str(def_id)][att_unit.get_unit_type()]
	if rate > 1:
		var damage:float = float(get_env("白兵伤害.伤害"))
		damage = damage * rate
		set_env("白兵伤害.伤害", damage)

	return false

