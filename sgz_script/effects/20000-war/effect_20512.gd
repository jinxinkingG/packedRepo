extends "effect_20000.gd"

#狂骨效果实现
#【狂骨】大战场,锁定技。你拥有<急功>，你的<急功>处于冷却状态时，你额外附加<忠绝>。

const MAIN_SKILL = "急功"
const CD_SKILL = "忠绝"

func appended_skill_list()->PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	ret.append(MAIN_SKILL)
	var mainSkill = StaticManager.get_skill(MAIN_SKILL)
	for effect in mainSkill.effects:
		if effect.type != "主动":
			continue
		var cd = SkillHelper.get_skill_cd(20000, effect.id, actorId, mainSkill.name)
		if cd > 0:
			ret.append(CD_SKILL)
			return ret
	return ret
