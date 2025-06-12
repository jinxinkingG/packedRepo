extends "effect_20000.gd"

#天义诱发技 #胜利触发 #追击
#【天义】大战场,诱发技。若你白兵战获胜，可以选择交战者之外的1名敌将。你对其进行攻击宣言。每回合限1次。

const EFFECT_ID = 20111
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20020()->bool:
	var bf = DataManager.get_current_battle_fight()
	var loser = bf.get_loser()
	if loser == null:
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != me.actorId:
		# 不是胜利方
		return false

	var targetIds = []
	for targetId in get_enemy_targets(me):
		if targetId == loser.actorId:
			continue
		targetIds.append(targetId)
	return targetIds.size() > 0

func effect_20111_start():
	var bf = DataManager.get_current_battle_fight()

	var targetIds = []
	for targetId in get_enemy_targets(me):
		if targetId == bf.loserId:
			continue
		targetIds.append(targetId)
	if targetIds.empty():
		LoadControl.end_script()
		return
	if not wait_choose_actors(targetIds, "选择【{0}】发动目标"):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000()->void:
	wait_for_choose_actor(FLOW_BASE + "_2", false)
	return

func effect_20111_2():
	var targetId = DataManager.get_env_int("武将")
	var msg = "丈夫三尺剑\n当立不世功\n{0}受死！".format([
		DataManager.get_actor_naughty_title(targetId, me.actorId)
	])
	play_dialog(me.actorId, msg, 0, 2001)
	map.next_shrink_actors = [me.actorId, targetId]
	return

func on_view_model_2001()->void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_3")
	return

func effect_20111_3():
	var targetId = DataManager.get_env_int("武将")

	ske.cost_war_cd(1)

	map.next_shrink_actors = []
	start_battle_and_finish(me.actorId, targetId)
	return
