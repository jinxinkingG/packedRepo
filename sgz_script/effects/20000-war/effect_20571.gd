extends "effect_20000.gd"

# 闻鼓锁定技部分
#【闻鼓】大战场，锁定技。你的队友发动任意主动技时，你击鼓响应，令己方全体机动力加2，同时，此技能变为主动技，你可主动击鼓，令己方全体机动力+3，然后你可再次发动，为自己机动力+4，然后技能进入冷却。

const AP_BONUS = 2
const ACTIVE_EFFECT_ID = 20572

func on_trigger_20040() -> bool:
	if ske.actorId == actorId:
		return false
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) > 0:
		return false
	ske.change_actor_ap(actorId, 2)
	for teammate in me.get_teammates(false, true):
		ske.change_actor_ap(teammate.actorId, 2)
	ske.war_report()
	# 标记解锁主动技
	ske.set_war_skill_val(1, 1, ACTIVE_EFFECT_ID)
	SoundManager.play_se2("res://resource/sounds/se/drums.ogg")
	var msg = "起鼓应戈矛，与子偕作！\n（【{0}】令全军机动力 +{1}\n（主动技解锁".format([
		ske.skill_name, AP_BONUS,
	])
	me.attach_free_dialog(msg, 0)
	return false
