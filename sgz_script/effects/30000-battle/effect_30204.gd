extends "effect_30000.gd"

#上将小战场效果
#【上将】大战场&小战场，锁定技。若你是本方武力最高的武将或之一，你的武力+10（大战场面板最高99，小战场可以突破99）

const WAR_EFFECT_ID = 20372

func on_trigger_30005()->bool:
	if ske.get_war_skill_val_int(WAR_EFFECT_ID) <= 0:
		return false
	var msg = "上将{0}在此\n{1}速来大战三百合！".format([
		me.get_name(),
		DataManager.get_actor_naughty_title(enemy.actorId, me.actorId),
	])
	append_free_dialog(me, msg, 0)
	return false
