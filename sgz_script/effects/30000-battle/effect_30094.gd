extends "effect_30000.gd"

#陷阵效果实现
#【陷阵】小战场，锁定技。你默认4步4弓，白刃战有特定阵型。你的步兵：攻击距离变为1~2，攻击具备穿刺效果，基础减伤倍率+0.3。非城战，你的弓兵：基础减伤0.1，攻击到骑兵时，可以额外攻击一次。

const ENHANCEMENT_MELEE = {
	"穿刺距离": 1,
	"近战距离": 2,
	"额外免伤": 0.3,
	"BUFF": 1,
}

const ENHANCEMENT_ARCHER = {
	"额外免伤": 0.1,
	"BUFF": 1,
}

func on_trigger_30003() -> bool:
	var data = {
		"兵种数量": {"步":4, "弓":4},
		"分配顺序": ["步", "弓"],
	}
	# 固定阵型 12/13
	var formation = 11312
	if actorId == bf.get_attacker_id():
		data["攻方阵型"] = formation
	else:
		data["守方阵型"] = formation

	bf.update_extra_formation_setting(actorId, ske.skill_name, "特殊", data)

	return false

func on_trigger_30009() -> bool:
	# 每回合开始时，清除连射标记，避免上一轮发动连射未清除
	for bu in bf.battle_units(actorId):
		if bu.get_unit_type() != "弓":
			continue
		bu.dic_combat.erase("陷阵.连射")
	return false

func on_trigger_30023()->bool:
	# 陷阵比较特殊，「非守城」不能直接通过配置实现，技能里判断
	var defendingCity = true
	if not bf.get_terrian() in StaticManager.CITY_BLOCKS_EN:
		defendingCity = false
	if bf.get_defender_id() != me.actorId:
		defendingCity = false
	if defendingCity:
		return false
	var bu = ske.battle_is_unit_hit_by(["弓"], ["骑"], ["射箭"])
	if bu == null:
		return false
	if bu.dic_combat.has("陷阵.连射"):
		bu.dic_combat.erase("陷阵.连射")
	else:
		bu.wait_action_times = 1
		bu.dic_combat["陷阵.连射"] = 1
	return false

func on_trigger_30024() -> bool:
	# 陷阵比较特殊，「非守城」不能直接通过配置实现，技能里判断
	var defendingCity = true
	if not bf.get_terrian() in StaticManager.CITY_BLOCKS_EN:
		defendingCity = false
	if bf.get_defender_id() != actorId:
		defendingCity = false
	ske.battle_enhance_current_unit(ENHANCEMENT_MELEE, ["步"])
	if defendingCity:
		return false
	ske.battle_enhance_current_unit(ENHANCEMENT_ARCHER, ["弓"])
	return false
