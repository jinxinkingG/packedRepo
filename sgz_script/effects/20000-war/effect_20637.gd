extends "effect_20000.gd"

# 钧发效果部分
#【钧发】大战场，限定技。你方总兵力比对方总兵力小3000以上时才能发动。你可指定1名己方将领机动力翻倍；若以此法指定自己，则你当回合用伤兵计成功率+20%，计策造成的士兵伤害+20%。

const ACTIVE_EFFECT_ID = 20636

func on_trigger_20011() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if targetId != actorId:
		return false
	change_scheme_damage_rate(20)
	return false

func on_trigger_20017() -> bool:
	var targetId = ske.get_war_skill_val_int(ACTIVE_EFFECT_ID, -1, -1)
	if targetId != actorId:
		return false
	change_scheme_chance(actorId, ske.skill_name, 20)
	return false
