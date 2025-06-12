extends "effect_30000.gd"

#弓骑锁定技 #骑兵强化
#【弓骑】小战场，锁定技。非城战，你的战术持续期间，你的骑兵默认可对2-3距离的敌人进行射箭攻击，基础伤害倍率0.7，基础减伤-0.15。生效一次后失去此技能。

const ENHANCEMENT = {
	"射击距离": 3,
	"额外免伤": -0.15,
	"图像": "1-2.png",
	"新图像": "1-2.png",
	"BUFF": 1,
}

func on_trigger_30024()->bool:
	if ske.get_battle_skill_val_int() > 0:
		ske.battle_enhance_current_unit(ENHANCEMENT, ["骑"])
	return false

func on_trigger_30009()->bool:
	var buffed = false
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] <= 0:
			continue
		buffed = true
		break
	if buffed:
		return false
	# 未找到任何小战场 buff, 尝试取消效果
	ske.set_battle_skill_val(0)
	for bu in DataManager.battle_units:
		if bu == null or bu.disabled or bu.leaderId != actorId:
			continue
		if bu.get_unit_type() != "骑":
				continue
		if not bu.dic_combat.has(ske.skill_name):
			continue
		bu.dic_combat.erase(ske.skill_name)
		bu.reset_combat_info()
	return false

func on_trigger_30010()->bool:
	for buff in StaticManager.CONTINUOUS_TACTICS:
		if me.get_buff(buff)["回合数"] <= 0:
			continue
		# 找到任意一个小战场 buff，尝试触发
		ske.set_battle_skill_val(1)
		var affected = 0
		for bu in DataManager.battle_units:
			if bu == null or bu.disabled or bu.leaderId != actorId:
				continue
			if bu.get_unit_type() != "骑":
				continue
			bu.init_combat_info("骑")
			bu.dic_combat[ske.skill_name] = 1
			affected += 1
		if affected > 0:
			DataManager.set_env("战术补充对话", "【{0}】发动，看我骑射之威！".format([ske.skill_name]))
			DataManager.set_env("战术补充对话表情", 0)
		break
	return false

func on_trigger_30099()->bool:
	if ske.get_battle_skill_val_int() > 0:
		ske.remove_war_skill(actorId, ske.skill_name)
	return false
