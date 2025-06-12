extends "effect_30000.gd"

# 忠侍效果
#【忠侍】小战场，锁定技。与你相邻的士兵会自动替你挡刀。士兵受到的兵力损伤=原本你应受伤害的5倍。每次白刃战，你的士兵至多累积帮你抵挡4次。

const LIMIT = 4

func on_trigger_30011() -> bool:
	var fromBU = ske.battle_is_unit_hit_by(UNIT_TYPE_SOLDIERS, ["将"], ["ALL"], true)
	if fromBU == null:
		return false
	var actorUnit = me.battle_actor_unit()
	if actorUnit == null or actorUnit.disabled:
		return false

	var damage = DataManager.get_env_int("白兵伤害.伤害")
	if damage <= 0:
		return false

	var times = ske.battle_get_skill_val_int()
	if times >= LIMIT:
		return false
	ske.battle_set_skill_val(times + 1)

	damage *= 5

	var candidates = []
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = actorUnit.unit_position + dir
		var bu = DataManager.get_battle_unit_by_position(pos)
		if bu == null or bu.disabled:
			continue
		if not bu.is_soldier() or bu.leaderId != actorId:
			continue
		candidates.append(bu)
	if candidates.empty():
		return false
	candidates.shuffle()
	var bu = candidates[0]
	var status = "{0} -{1}#FF0000".format([ske.skill_name, damage])
	bu.add_status_effect(status)
	ske.battle_change_unit_hp(bu, -damage)
	DataManager.set_env("白兵伤害.伤害", 0)
	return false
