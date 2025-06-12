extends "effect_30000.gd"

#陷阵效果实现
#【陷阵】小战场，锁定技。你默认4步4弓，你的步兵攻击距离变为1~2，基础减伤倍率+0.3，攻击具备穿刺效果；非守城，你的弓兵基础减伤0.1，攻击到骑兵时，可以额外攻击一次。

const EFFECT_ID = 30094

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

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	# 陷阵比较特殊，「非守城」不能直接通过配置实现，技能里判断
	var defendingCity = true
	if not bf.get_terrian() in StaticManager.CITY_BLOCKS_EN:
		defendingCity = false
	if bf.get_defender_id() != me.actorId:
		defendingCity = false
	match ske.trigger_Id:
		30003: # 决定阵型时
			var formationKey = "白兵.阵型优先.{0}".format([ske.skill_actorId])
			if get_env_int(formationKey) > 1:
				return false
			set_env("兵种数量", {"弓":4,"步":4})
			set_env("分配顺序", ["弓", "步"])
			set_env(formationKey, 1)
		30009: # 初始化完成后，每回合开始前
			# 每回合开始时，清除连射标记，避免上一轮发动连射未清除
			for bu in DataManager.battle_units:
				if bu == null or bu.disabled or bu.leaderId != me.actorId:
					continue
				if bu.get_unit_type() != "弓":
					continue
				bu.dic_combat.erase("陷阵.连射")
		30023: # 敌方士兵受到攻击时
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
		30024: # 单位初始化
			ske.battle_enhance_current_unit(ENHANCEMENT_MELEE, ["步"])
			if defendingCity:
				return false
			ske.battle_enhance_current_unit(ENHANCEMENT_ARCHER, ["弓"])
	return false
