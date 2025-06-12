extends "effect_20000.gd"

#策书大战场效果
#【策书】大战场,锁定技。获得此技能时，随机解锁上古神策 <落雷>、 <火神> 、<激石>、 <水龙> 之一。

const TARGET_SKILLS = [
	"落雷", "火神", "激石", "水龙",
]

func appended_skill_list() -> PoolStringArray:
	var ret = []
	if DataManager.get_current_scene_id() < 20000:
		return ret
	var me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return ret
	
	var attached = me.get_tmp_variable("策书", "")
	if attached == "":
		var skills = TARGET_SKILLS.duplicate()
		skills.shuffle()
		me.set_tmp_variable("策书", skills[0])
		ret.append(skills[0])
	else:
		ret.append(attached)
	return ret
