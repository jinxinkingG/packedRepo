extends "effect_40000.gd"

# 武烈单挑效果
#【武烈】大战场，锁定技。你方孙姓武将，进入小战场时，护甲+10点；进入单挑时，体力恢复10点，孙坚触发时，效果翻倍。你方君主为孙坚时，无视“孙姓”限制，但非孙姓触发，效果减半。每场战斗限1次。

const HP_BONUS = 10

func on_trigger_40011() -> bool:
	ske.battle_cd(99999)
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null:
		return false
	var wv = wa.war_vstate()
	if wv == null:
		return false
	var lord = wv.get_lord()
	var hp = 0
	if wa.actor().get_first_name() == "孙":
		hp = HP_BONUS
		if wa.actorId == StaticManager.ACTOR_ID_SUNJIAN:
			hp = HP_BONUS * 2
	elif lord.actorId == StaticManager.ACTOR_ID_SUNJIAN:
		hp = HP_BONUS / 2
	if hp <= 0:
		return false
	hp = ske.change_actor_hp(ske.actorId, hp)
	ske.battle_set_skill_val(hp)
	ske.battle_report()
	return hp > 0

func effect_40008_AI_start() -> void:
	goto_step("start")
	return

func effect_40008_start() -> void:
	var wa = DataManager.get_war_actor(ske.actorId)
	var hp = ske.battle_get_skill_val_int()
	var msg = "孙家男儿，谁惧决死！\n（{0}【{1}】效果\n（{2}体力回复{3} -> {4}".format([
		actor.get_name(), ske.skill_name, wa.get_name(), hp, wa.actor().get_hp(),
	])
	SceneManager.show_confirm_dialog(msg, actorId, 0)
	SceneManager.current_scene().update_actor_info()
	LoadControl.set_view_model(2990)
	return
