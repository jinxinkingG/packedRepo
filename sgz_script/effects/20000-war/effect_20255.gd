extends "effect_20000.gd"

#制霸锁定技 #进攻触发 #胜利触发 #机动力
#【制霸】大战场,锁定技。你方其他武将，进攻敌将获胜时，你获得其攻击消耗的一半机动力。

const EFFECT_ID = 20255

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if me.actorId == ske.actorId:
		# 自己鸡自己，算了
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null:
		return false
	if winner.actorId != ske.actorId:
		return false
	if winner.actorId != bf.get_attacker_id():
		# 不是攻方
		return false

	# 我方武将胜利
	var ap = int(bf.ap / 2)
	if ap <= 0:
		return false
	ske.change_actor_ap(me.actorId, ap)
	ske.war_report()
	var d = War_Character.DialogInfo.new()
	d.text = "{0}不愧我江东英杰！\n（{1}机动力 +{2}".format([
		DataManager.get_actor_honored_title(winner.actorId, me.actorId),
		me.get_name(), ap,
	])
	d.actorId = me.actorId
	d.mood = 2
	me.add_dialog_info(d)
	return false

