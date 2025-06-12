extends "effect_20000.gd"

#弘德锁定效果
#【弘德】大战场,锁定技。你被附加大战场负面状态时，队友全体获得X机动力。X=负面状态回合数*2，最高20

func on_trigger_20022()->bool:
	if me == null or me.disabled:
		return false

	var buffKey = "BUFF.{0}".format([actorId])
	var buff = DataManager.get_env_str(buffKey)
	if buff == "":
		return false
	var buffDecFlagKey = "BUFF.DEC.{0}".format([actorId])
	if DataManager.get_env_int(buffDecFlagKey) == 1:
		return false
	var turns = me.get_buff(buff)["回合数"]
	if turns <= 0:
		return false
	var buffInfo = StaticManager.get_buff(buff)
	if buffInfo.get_scene() != "大战场":
		return false
	if not buffInfo.is_negative():
		return false

	var ap = min(20, turns * 2)
	for wa in me.get_teammates(false):
		ske.change_actor_ap(wa.actorId, ap)
	ske.war_report()

	var msg = "我入困局，诸公当弘毅！\n（所有队友机动力 +{0}".format([ap])
	me.attach_free_dialog(msg, 2)
	return false

