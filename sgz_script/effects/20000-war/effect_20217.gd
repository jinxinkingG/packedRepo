extends "effect_20000.gd"

#急利锁定技 #胜利触发 #失败触发 #机动力
#【急利】大战场,主将锁定技。你方武将白兵胜利后，该武将机动力+4，你的机动力-4；若失败，你的机动力+4，该武将机动力-4。 （如果机动力不够，则全扣，0机动力则不触发。）

const TRANS_AP = 4

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if ske.skill_actorId == ske.actorId:
		# 自己鸡自己，算了
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		return false

	if loser.actorId == ske.actorId and loser.action_point > 0:
		# 我方武将失败，且有机动力
		ske.change_actor_ap(me.actorId, TRANS_AP)
		var reduced = ske.change_actor_ap(loser.actorId, -TRANS_AP)
		var d = War_Character.DialogInfo.new()
		d.text = "{0}如此无能！\n待我亲讨之\n（{1}夺取{2}{3}机动力".format([
			DataManager.get_actor_naughty_title(loser.actorId, me.actorId),
			me.get_name(), loser.get_name(), TRANS_AP
		])
		d.actorId = me.actorId
		d.mood = 0
		me.add_dialog_info(d)

	if winner.actorId == ske.actorId and me.action_point > 0:
		# 我方武将胜利，且“我”有机动力
		ske.change_actor_ap(winner.actorId, TRANS_AP)
		var reduced = ske.change_actor_ap(me.actorId, -TRANS_AP)
		var d = War_Character.DialogInfo.new()
		d.text = "{0}果然英勇\n速速追击！\n（{1}给予{2}{3}机动力".format([
			DataManager.get_actor_honored_title(winner.actorId, me.actorId),
			me.get_name(), winner.get_name(), TRANS_AP
		])
		d.actorId = me.actorId
		d.mood = 0
		me.add_dialog_info(d)

	ske.war_report()
	return false

