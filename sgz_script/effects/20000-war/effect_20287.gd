extends "effect_20000.gd"

#破竹被动效果
#【破竹】大战场，主将锁定技。你方回合，你方武将每击杀/俘虏一个敌将时，你方“武”排名前五的武将机动力+6。（若并列，允许超过五人）

const EFFECT_ID = 20287
const AP_GAIN = 6

func on_trigger_20027()->bool:
	# 触发武将的状态
	var targetActor = ActorHelper.actor(ske.actorId)
	if not targetActor.is_status_captured() and not targetActor.is_status_dead():
		return false

	# 判断是否我方回合
	var wf = DataManager.get_current_war_fight()
	if wf.current_war_vstate().id != me.wvId:
		return false

	# 判断来源是否我方武将
	var fromId = DataManager.get_env_int("战争.DISABLE.FROM")
	if fromId < 0:
		return false
	var from = me
	if fromId != actorId:
		from = DataManager.get_war_actor(fromId)
		if not me.is_teammate(from):
			return false

	# 排序并去重
	var affected = []
	var powers = []
	var all = me.war_vstate().get_war_actors(false, true)
	all.sort_custom(Global.actorComp, "by_actor_power")
	for wa in all:
		var power = wa.get_power()
		if powers.size() < 5:
			powers.append(power)
			affected.append(wa)
		elif power in powers:
			# 并列是可以的
			affected.append(wa)
		else:
			break

	var names = []
	for wa in affected:
		ske.change_actor_ap(wa.actorId, AP_GAIN, false)
		names.append(wa.get_name())
	if names.size() > 3:
		names[2] += "等{0}人".format([names.size()])
		names = names.slice(0, 2)
	ske.war_report()
	# 统一更新一次光环，避免重复更新耗时
	SkillHelper.update_all_skill_buff(ske.skill_name)

	var msg = "势如破竹，克期灭敌！\n（{0}机动力+6".format(["、".join(names)])
	me.attach_free_dialog(msg, 0)
	return false
