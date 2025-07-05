extends "effect_20000.gd"

#引伏
#【引伏】大战场,诱发技。你被发起攻击宣言的场合，你可以消耗5点机动力，发动：指定一个你方武将，其半路杀出，截杀对方，与对方进入白刃战，并使其战术值额外+（你的智*0.13），其本次白刃战胜利时，你的经验额外+500，每个回合限3次，战斗地形强制为平地。

const EFFECT_ID = 20149
const FLOW_BASE = "effect_" + str(EFFECT_ID)
const COST_AP = 5
const EXP_GAIN = 500
const TIMES_LIMIT = 3

func on_trigger_20015() -> bool:
	if bf.get_defender_id() != actorId:
		# 不是防守方
		return false
	var me = ske.get_war_actor()
	if me == null or me.disabled:
		return false
	if me.action_point < COST_AP:
		# 机动力不足，无法发动
		return false
	var marked = ske.get_war_skill_val_dic()
	if marked.has("times") and marked["times"] >= TIMES_LIMIT:
		ske.cost_war_cd(1)
		return false
	return true

func on_trigger_20020() -> bool:
	# 检查引伏标记
	var marked = ske.get_war_skill_val_dic()
	if not marked.has("times") or not marked.has("ing"):
		return false
	marked.erase("ing")
	ske.set_war_skill_val(marked, 1)
	if marked["times"] >= TIMES_LIMIT:
		ske.cost_war_cd(1)
	if bf.loserId < 0:
		# 胜负未分
		return false
	if bf.loserId == ske.actorId:
		# 队友失败了
		return false
	# 胜利了，加经验
	ske.change_actor_exp(ske.skill_actorId, EXP_GAIN)
	ske.war_report()
	var me = ske.get_war_actor()
	var d = War_Character.DialogInfo.new()
	d.actorId = me.actorId
	d.text = "多谢{0}仗义相助！\n（{1}经验增加{2}".format([
		DataManager.get_actor_honored_title(ske.actorId, ske.skill_actorId),
		me.get_name(), EXP_GAIN,
	])
	d.mood = 1
	me.add_dialog_info(d)
	return false

func effect_20149_AI_start() -> void:
	var replacedId = DataManager.get_env_int("目标")
	var me = ske.get_war_actor()
	if me.action_point < COST_AP:
		LoadControl.end_script()
		return
	# 尝试寻找比我强很多的队友
	var powerfulId = -1
	var maxPower = -1
	for targetId in get_teammate_targets(me):
		if targetId == me.get_main_actor_id():
			# 别把主将拉下水
			continue
		var actor = ActorHelper.actor(targetId)
		var wa = DataManager.get_war_actor(targetId)
		var morale = wa.calculate_battle_morale(actor.get_power(), actor.get_leadership())
		var power = morale * actor.get_soldiers()
		if power > maxPower:
			powerfulId = targetId
			maxPower = power
	if powerfulId < 0:
		# 啥也没找到
		LoadControl.end_script()
		return
	var actor = ActorHelper.actor(ske.skill_actorId)
	var morale = me.calculate_battle_morale(actor.get_power(), actor.get_leadership())
	var myPower = morale * actor.get_soldiers()
	if maxPower < myPower * 1.3:
		# 你也没强到哪去。。。
		LoadControl.end_script()
		return
	DataManager.set_env("目标", powerfulId)
	var msg = "{0}小儿\n{1}在此专候多时了！\n（{2}发动【{3}】".format([
		bf.get_attacker().get_name(),
		ActorHelper.actor(powerfulId).get_name(),
		me.get_name(), ske.skill_name,
	])
	play_dialog(powerfulId, msg, 0, 3000)
	return

func on_view_model_3000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20149_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var targetIds = get_teammate_targets(me)
	if targetIds.empty():
		var msg = "附近没有队友可以发动【{0}】".format([ske.skill_name])
		play_dialog(actorId, msg, 3, 2990)
		return
	var msg = "选择队友发动【{0}】".format([ske.skill_name])
	if not wait_choose_actors(targetIds, msg, true):
		return
	LoadControl.set_view_model(2000)
	return

func on_view_model_2000() -> void:
	wait_for_choose_actor(FLOW_BASE + "_selected", false)
	return

func effect_20149_selected() -> void:
	map.cursor.hide()
	var msg = "发动【{0}】\n需{1}点机动力\n可否？".format([
		ske.skill_name, COST_AP
	])
	play_dialog(actorId, msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_confirmed", false)
	return

func effect_20149_confirmed() -> void:
	var replacedId = DataManager.get_env_int("目标")
	var msg = "{0}小儿\n{1}在此专候多时了！".format([
		bf.get_attacker().get_name(),
		ActorHelper.actor(replacedId).get_name(),
	])
	play_dialog(replacedId, msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_fight")
	return

func effect_20149_fight() -> void:
	var replacedId = DataManager.get_env_int("目标")

	ske.cost_ap(COST_AP)
	# 记录次数并设置引伏标记
	var marked = ske.get_war_skill_val_dic()
	if not marked.has("times"):
		marked["times"] = 0
	marked["times"] += 1
	marked["ing"] = 1
	ske.set_war_skill_val(marked, 1)
	# 反守为攻
	var attacker = bf.get_attacker_id()
	bf.attackerId = replacedId
	bf.defenderId = attacker
	var msg = "{0}与{1}攻守互换".format([
		bf.get_defender().get_name(), bf.get_attacker().get_name(),
	])
	ske.append_message(msg, -1)
	# 改为平原战
	bf.terrian = "land"
	ske.append_message("战斗改为平原战", -1)
	ske.war_report()
	LoadControl.end_script()
	return
