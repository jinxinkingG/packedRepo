extends "effect_20000.gd"

#攻心锁定技
#【攻心】大战场，锁定技。你用伤兵计时，不计算命中率，直接造成士兵流失，不视为伤害。回合结束或战争结束时，流失的兵力重新回到对方部队。每回合限3次

# 用特殊 key 记录生效次数
const KEY_TIMES = "TIMES"
const TIMES_LIMIT = 3
# 用特殊 key 记录标记计策生效并排除一次计策多次累加
const KEY_ACTION_STATUS = "ACTION"

func on_trigger_20010()->bool:
	# 计策计算命中率前

	# 默认清除行动标记
	var recorded = ske.get_war_skill_val_dic()
	recorded[KEY_ACTION_STATUS] = 0
	ske.set_war_skill_val(recorded, 1)

	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(actorId) != actorId:
		return false
	if KEY_TIMES in recorded and recorded[KEY_TIMES] >= TIMES_LIMIT:
		return false
	if se.skill != ske.skill_name:
		return false

	recorded[KEY_ACTION_STATUS] = 1
	ske.set_war_skill_val(recorded, 1)
	se.set_must_success(actorId, ske.skill_name)
	return false

func on_trigger_20011()->bool:
	# 写入计策伤兵量后（用计者触发）
	var recorded = ske.get_war_skill_val_dic()
	if not KEY_ACTION_STATUS in recorded or Global.intval(recorded[KEY_ACTION_STATUS]) <= 0:
		return false

	var damage = DataManager.get_env_int("计策.ONCE.伤害")
	var targetId = DataManager.get_env_int("计策.ONCE.伤害武将")
	if damage <= 0 or targetId < 0:
		return false

	# 需要看实际士兵调整伤害值
	damage = min(ActorHelper.actor(targetId).get_soldiers(), damage)

	var key = str(targetId)
	if not key in recorded:
		recorded[key] = 0
	recorded[key] += damage

	# 确保计数器在一次计策中只加一次
	if recorded[KEY_ACTION_STATUS] == 1:
		if not KEY_TIMES in recorded:
			recorded[KEY_TIMES] = 0
		recorded[KEY_TIMES] += 1
		recorded[KEY_ACTION_STATUS] = 2
	ske.set_war_skill_val(recorded, 1)

	# 计策伤害清零
	DataManager.set_env("计策.ONCE.伤害", 0)
	# 手动扣减
	DataManager.damage_sodiers(actorId, targetId, damage)
	# 追加信息
	var se = DataManager.get_current_stratagem_execution()
	se.append_result("兵力流失", "", damage, targetId)
	return false

func on_trigger_20016()->bool:
	# 大战场我方回合结束
	_recover_damage()
	return false

func on_trigger_20021() -> bool:
	var se = DataManager.get_current_stratagem_execution()
	if not se.damage_soldier():
		return false
	if se.get_action_id(actorId) != actorId:
		return false
	se.skill = ske.skill_name
	se.set_env("兵力流失", 1)
	return false

func on_trigger_20027()->bool:
	# 离开战场前
	_recover_damage()
	return false

func _recover_damage()->bool:
	var recorded = ske.get_war_skill_val_dic()
	for key in recorded:
		var targetId = int(key)
		var damage = int(recorded[key])
		var wa = DataManager.get_war_actor(targetId)
		if wa == null:
			continue
		var limit = DataManager.get_actor_max_soldiers(targetId)
		ske.change_actor_soldiers(targetId, damage, limit)
	ske.war_report()
	return false
