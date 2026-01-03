extends "effect_30000.gd"

#陷阵效果实现
#【陷阵】小战场，锁定技。你默认4步4弓，你的步兵攻击距离变为1~2，基础减伤倍率+0.3，攻击具备穿刺效果；非守城，你的弓兵基础减伤0.1，攻击到骑兵时，可以额外攻击一次。

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
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "常规", {
			"兵种数量": {"弓":4,"步":4},
			"分配顺序": ["弓", "步"],
		}
	)
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
