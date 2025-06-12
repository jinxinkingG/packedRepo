extends "effect_20000.gd"

#千追限定技部分
#【千追】大战场，限定技。你可指定1名武力>90的敌将为目标发动。直到战争结束前，你朝靠近目标的方向移动时，默认只需1点机动力；除非目标离开战场，否则你不能对其他武将攻击或用计。

const EFFECT_ID = 20548
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func effect_20548_start() -> void:
	var targets = []
	for targetId in get_enemy_targets(me, true, 999):
		var wa = DataManager.get_war_actor(targetId)
		if wa.actor().get_power() <= 90:
			continue
		targets.append(targetId)
	if targets.empty():
		var msg = "没有值得追杀的目标"
		play_dialog(actorId, msg, 2, 2999)
		return
	var msg = "对何人发动【{0}】？"
	if not wait_choose_actors(targets, msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20548_2() -> void:
	var targetId = DataManager.get_env_int("目标")

	ske.cost_war_cd(99999)
	ske.set_war_skill_val(targetId)
	ske.war_report()

	var msg = "{0}匹夫\n千里万里，取汝首级！".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 0, 2999)
	return
