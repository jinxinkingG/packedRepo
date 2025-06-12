extends "effect_20000.gd"

#同心锁定技 #胜利触发
#【同心】大战场，锁定技。你方其他武将白刃战获胜时，本回合你下一次使用的[火计]只消耗3点机动力。

const EFFECT_ID = 20016

func check_trigger_correct()->bool:
	match self.triggerId:
		20008: # 白兵结束
			_after_battle()
		20004: # 计策菜单
			_scheme_menu()
		20005: # 计策消耗判断
			_scheme_cost()
	return false

func _after_battle()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	var loser = bf.get_loser()
	if loser == null:
		return false
	if ske.actorId == me.actorId:
		# 自己不触发
		return false
	var winner = loser.get_battle_enemy_war_actor()
	if winner == null or winner.actorId != ske.actorId:
		# 不是胜利方
		return false
	# 为自己设定同心标记
	ske.set_war_skill_val(1, 1)
	return false

func _scheme_menu()->void:
	if get_skill_triggered_times(self.actorId, EFFECT_ID) <= 0:
		return
	if not check_env(["战争.计策列表", "战争.计策提示"]):
		return
	var schemes = Array(get_env("战争.计策列表"))
	var msg = str(get_env("战争.计策提示"))
	var replaced = get_env("战争.计策替换")
	if typeof(replaced) != TYPE_DICTIONARY:
		replaced = {}

	for scheme in schemes:
		var name = str(scheme[0])
		var cost = int(scheme[1])
		if name == "火计":
			scheme[1] = min(cost, 3)
			if scheme.size() < 3:
				scheme.append("")
			scheme[2] = "同心"
	change_stratagem_list(self.actorId, schemes)
	return

func _scheme_cost()->void:
	if get_skill_triggered_times(self.actorId, EFFECT_ID) <= 0:
		return
	var cost = get_env_int("计策.消耗.所需")
	cost = min(3, cost)
	if not set_scheme_ap_cost("火计", cost):
		return
	if get_env_int("计策.消耗.仅对比") == 0:
		# 确认发动时，直接清空标记
		clear_skill_triggered_times(self.actorId, EFFECT_ID)
	return
