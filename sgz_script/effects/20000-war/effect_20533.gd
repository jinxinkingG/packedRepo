extends "effect_20000.gd"

#诚治主动技
#【诚治】大战场，主动技。对方场上的人数至少为3时，你可以令对方选择其场上的1名将领为目标，并消耗你5点机动力发动。目标的机动力+5；之后由你选择下列一项效果适用：1.下次对方回合，目标不能进行攻击宣言；2. 下次对方回合，目标不能用计。每回合限1次。

const EFFECT_ID = 20533
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 5

# TODO 目前只支持玩家发动
# 如果要支持 AI 发动，触发、选择和流程中身份判断需要同步修改

func effect_20533_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	if me.get_enemy_war_actors(true).size() < 3:
		var msg = "敌军不足3人\n不可发动"
		play_dialog(actorId, msg, 2, 2999)
		return
	var targets = get_enemy_targets(me)
	if targets.empty():
		var msg = "没有可以发动的目标"
		play_dialog(actorId, msg, 3, 2999)
		return
	var msg = "选择目标发动【{0}】"
	if not wait_choose_actors(targets, msg):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_2")
	return

func effect_20533_2() -> void:
	var targetId = DataManager.get_env_int("目标")
	var msg = "消耗{0}机动力\n对{1}发动【{2}】\n可否？".format([
		COST_AP, ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_3")
	return

func effect_20533_3() -> void:
	var targetId = DataManager.get_env_int("目标")
	var options = ["禁止攻击", "禁用计策"]
	var msg = "请选择附加效果："
	play_dialog(actorId, msg, 2, 2002, true, options)
	return

func on_view_model_2002() -> void:
	var option = wait_for_skill_option()
	var lsc = SceneManager.actor_dialog.lsc
	if option >= 0 and option < lsc.items.size():
		DataManager.set_env("目标项", lsc.items[option])
		goto_step("4")
	return

func effect_20533_4() -> void:
	var targetId = DataManager.get_env_int("目标")
	var option = DataManager.get_env_str("目标项")
	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP, true)
	ske.change_actor_ap(targetId, COST_AP)
	ske.set_war_skill_val(option, 99999, -1, targetId)
	ske.war_report()

	var msg = "诚道以制\n{0}徒虽众而不能用".format([
		ActorHelper.actor(targetId).get_name(),
	])
	play_dialog(actorId, msg, 1, 2999)
	return
