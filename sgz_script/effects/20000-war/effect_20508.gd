extends "effect_20000.gd"

#人偶主动技
#【人偶】大战场，限定技。选择一名敌将为目标，消耗10点机动力发动。召唤一个人偶武将加入你方，属性和技能均变为与目标相同。战争中只能存在一个人偶。

const EFFECT_ID = 20508
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const COST_AP = 10

func effect_20508_start()->void:
	var wf = DataManager.get_current_war_fight()
	if wf.get_env_int("人偶") >= 0:
		var msg = "只能存在一个人偶！"
		play_dialog(actorId, msg, 2, 2999)
		return
	if not assert_action_point(actorId, COST_AP):
		return
	if not wait_choose_actors(get_enemy_targets(me)):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_go")
	return

func effect_20508_go()->void:
	var wf = DataManager.get_current_war_fight()
	var targetId = DataManager.get_env_int("目标")
	var target = DataManager.get_war_actor(targetId)
	var wv = me.war_vstate()

	var msg = "太玄在上，如律令敕！"

	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(99999)

	for item in target.actor().get_equip_feature_all("仙术无效"):
		if item[1] > 0:
			var response = "旁门左道，于我皆为虚妄！\n（「{0}」仙术无效".format([
				item[0].name(),
			])
			target.attach_free_dialog(response, 0)
			play_dialog(actorId, msg, 0, 2999)
			return

	wf.set_env("人偶", targetId)
	var wa = War_Actor.new(wv.vstate().id, wv.id)
	wa.actorId = StaticManager.ACTOR_ID_RENOU + targetId
	wa.action_point = target.action_point
	wa.disabled = false
	wa.position = Vector2(-1, -1)
	for dir in StaticManager.NEARBY_DIRECTIONS:
		var pos = me.position + dir
		if me.try_move(pos):
			wa.position = pos
			break
	wa.poker_point = target.poker_point
	wa.five_phases = target.five_phases
	wv.add_war_actor(wa, true)

	map.draw_actors()
	ske.war_report()

	play_dialog(actorId, msg, 0, 2999)
	return

func on_view_model_2999()->void:
	wait_for_skill_result_confirmation()
	return
