extends "effect_20000.gd"

#牵制诱发技 #替代防御
#【牵制】大战场，诱发技。敌将对你相邻的队友发起攻击宣言时，消耗5机动力才能发动，你代替成为被攻击目标。每回合限1次。

const EFFECT_ID = 20352
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5

func on_trigger_20015()->bool:
	var bf = DataManager.get_current_battle_fight()
	if me == null or me.disabled:
		return false
	if ske.actorId != bf.get_defender_id():
		# 不是防守方，跳过
		return false
	if ske.actorId == actorId:
		# 自己没必要触发
		return false
	#机动力不足，无法发动
	if me.action_point < COST_AP:
		return false
	var teammate = DataManager.get_war_actor(ske.actorId)
	if teammate == null:
		return false
	var dir = teammate.position - me.position
	if not dir in StaticManager.NEARBY_DIRECTIONS:
		# 不相邻
		return false
	if me.get_controlNo() < 0 \
		and me.get_soldiers() <= bf.get_defender().get_soldiers() \
		and me.get_soldiers() < 1500:
		# AI 发动条件判断
		return false
	return true

func effect_20352_AI_start():
	goto_step("2")
	return

func effect_20352_start():
	var msg = "发动{0}\n需{1}点机动力\n可否？".format([ske.skill_name, COST_AP])
	play_dialog(actorId, msg, 2, 2000, true)
	return

func on_view_model_2000()->void:
	wait_for_yesno(FLOW_BASE + "_2", false)
	return

func effect_20352_2():
	var bf = DataManager.get_current_battle_fight()

	ske.cost_war_cd(1)
	ske.cost_ap(COST_AP)
	ske.replace_battle_defender(ske.actorId)
	# 标记以配合功著效果
	ske.set_war_skill_val(1, 1)
	ske.war_report()

	var msg = "{0}在侧\n{1}也敢长驱直入吗！\n（发动【{3}】替代防御".format([
		DataManager.get_actor_self_title(actorId),
		DataManager.get_actor_naughty_title(bf.get_attacker_id(), me.actorId),
		me.get_name(), ske.skill_name,
	])
	play_dialog(actorId, msg, 0, 2990)
	return
