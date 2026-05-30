extends "effect_20000.gd"

# 垫机诱发技（被攻击时触发部分）
#【垫机】大战场，诱发技。你机动力为0时被攻击的场合。可选择攻击者以外的1名敌将为目标发动，
# 你在当次白刃战中损失的兵力，在小战场结束后由目标武将代为损失。每回合限1次。

const EFFECT_ID = 20726
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20015() -> bool:
	# 必须是被攻击方（自己是 bf.targetId）
	if bf == null:
		return false
	if actorId != bf.targetId:
		return false

	# 机动力必须为0
	if me.action_point > 0:
		return false

	# 获取攻击者
	var attacker = bf.get_attacker()
	if attacker == null or attacker.disabled:
		return false

	var candidates = get_candidates(me)
	return not candidates.empty()

func effect_20726_AI_start() -> void:
	var candidates = get_candidates(me)
	if candidates.empty():
		skill_end_clear()
		return

	var bestId = candidates[0]
	var bestSoldiers = 0
	for cid in candidates:
		var wa = DataManager.get_war_actor(cid)
		if wa == null:
			continue
		var s = wa.get_soldiers()
		if s > bestSoldiers:
			bestSoldiers = s
			bestId = cid
	DataManager.set_env("目标", bestId)
	goto_step("confirmed")
	return

func effect_20726_start() -> void:
	var candidates = get_candidates(me)
	if not wait_choose_actors(candidates):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", false)
	return

func effect_20726_selected() -> void:
	var targetId = DataManager.get_env_int("目标")
	var attackerName = DataManager.get_actor_naughty_title(bf.fromId, actorId)

	var msg = "{0}来势汹汹\n对{1}发动【{2}】\n战后转嫁损失？".format([
		attackerName, ActorHelper.actor(targetId).get_name(),
		ske.skill_name,
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20726_confirmed() -> void:
	var targetId = DataManager.get_env_int("目标")

	# 设置CD（每回合限1次）
	ske.cost_war_cd(1)

	# 记录垫机状态到技能变量，供 effect_20727 使用
	var soldiers = actor.get_soldiers()
	ske.set_war_skill_val([targetId, soldiers])

	skill_end_clear()
	return

# 获取攻击者以外的敌方将领
func get_candidates(me:War_Actor) -> PoolIntArray:
	var attacker = bf.get_attacker()
	# 获取攻击者以外，且可选择的敌方将领
	var candidates = []
	for enemyId in get_enemy_targets(me):
		if enemyId == attacker.actorId:
			continue
		candidates.append(enemyId)
	return candidates
