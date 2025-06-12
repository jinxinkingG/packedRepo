extends "effect_20000.gd"

# 闻鼓主动技部分
#【闻鼓】大战场，锁定技。每日限1次：你的队友发动任意主动技时，你击鼓响应，令己方全体机动力加2；同时，此技能变为主动技，你可主动击鼓，为自己机动力+4；之后你可再次发动，令己方全体机动力+3，技能进入3回合冷却。

const EFFECT_ID = 20572
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const PASSIVE_EFFECT_ID = 20571
const AP_BONUS = 3

func effect_20572_start() -> void:
	var flag = ske.get_war_skill_val_int()
	if flag == 1:
		# 第一次发动
		SoundManager.play_se2("res://resource/sounds/se/drums.ogg")
		ske.change_actor_ap(actorId, AP_BONUS + 1)
		ske.set_war_skill_val(2, 1)
		var msg = "再鼓起清歌，孤凤飞鸣\n（【{0}】机动力 +{1}".format([
			ske.skill_name, AP_BONUS + 1,
		])
		me.attach_free_dialog(msg, 0)
	elif flag == 2:
		# 第二次发动
		SoundManager.play_se2("res://resource/sounds/se/drums.ogg")
		ske.change_actor_ap(actorId, AP_BONUS)
		for teammate in me.get_teammates(false, true):
			ske.change_actor_ap(teammate.actorId, AP_BONUS)
		ske.cost_war_cd(3)
		SkillHelper.set_skill_cd(20000, PASSIVE_EFFECT_ID, actorId, 3, ske.skill_name)
		var msg = "终鼓振甲兵，与子偕行！\n（全军机动力 +{1}\n（【{0}】冷却三回合".format([
			ske.skill_name, AP_BONUS,
		])
		me.attach_free_dialog(msg, 0)
	else:
		goto_step("end")
		return
	ske.war_report()
	goto_step("end")
	return

func effect_20572_end() -> void:
	skill_end_clear()
	FlowManager.add_flow("player_skill_end_trigger")
	return
