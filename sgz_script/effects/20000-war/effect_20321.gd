extends "effect_20000.gd"

#急攻发动后的锁定效果
#【急攻】大战场，限定技。发动后你立刻增加15点机动力。下个回合开始时，你可恢复的机动力为X（X=发动回合你对敌将造成的兵力伤害÷100。最大不超过25）。

const ACTIVE_EFFECT_ID = 20320
const EFFECT_ID = 20321

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	match ske.trigger_Id:
		20004: # 计策列表，显示伤害
			_scheme_menu(ske)
		20013: # 回合初始
			_round_init(ske)
		20012: # 计策结束
			var se = DataManager.get_current_stratagem_execution()
			if se.get_action_id(me.actorId) != me.actorId:
				return false
			_record_damage(ske, se.get_total_damage())
		20016: # 回合结束
			_record_ap(ske, me.action_point)
		20020: # 白刃结束
			_after_battle(ske)
	return false

func _scheme_menu(ske:SkillEffectInfo):
	var dic = _get_recorded_status(ske)
	if int(dic["damage"]) <= 0:
		return
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return false
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))
	var msgs = Array(msg.split("\n"))
	msgs.append("【急攻】战果：{0}".format([int(dic["damage"])]))
	msg = "\n".join(msgs.slice(0, 2))
	change_stratagem_list(ske.skill_actorId, schemes, msg)
	return

func _round_init(ske:SkillEffectInfo):
	# 无条件清除标记
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	# 判断是否有特殊机动力设定逻辑
	var dic = _get_recorded_status(ske)
	var apBonus = int(int(dic["damage"]) / 100)
	apBonus = min(25, apBonus)
	if apBonus <= 0:
		return
	ske.change_actor_ap(ske.skill_actorId, apBonus)
	# 清除记录变量
	ske.set_war_skill_val(null, 0)
	ske.war_report()
	return

func _after_battle(ske:SkillEffectInfo):
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	var prev = 0
	var current = 0
	if me.actorId == bf.get_attacker_id():
		prev = bf.defenderSoldiers
		current = bf.get_defender().get_soldiers()
	elif me.actorId == bf.get_defender_id():
		prev = bf.attackerSoldiers
		current = bf.get_attacker().get_soldiers()
	else:
		return false
	if current < prev:
		_record_damage(ske, prev - current)
	return

func _get_recorded_status(ske:SkillEffectInfo)->Dictionary:
	var ret = {"damage": 0, "ap": 0}
	var dic = ske.get_war_skill_val_dic()
	for k in ["damage", "ap"]:
		if dic.has(k):
			ret[k] = int(dic[k])
	return ret

func _record_damage(ske:SkillEffectInfo, damage:int):
	var dic = _get_recorded_status(ske)
	dic["damage"] += damage
	ske.set_war_skill_val(dic)
	return

func _record_ap(ske:SkillEffectInfo, ap:int):
	var dic = _get_recorded_status(ske)
	dic["ap"] = ap
	ske.set_war_skill_val(dic)
	return
