extends "effect_30000.gd"

#劫营小战场的锁定效果，包括阵型和结束时退回所有保存的兵力，及【魄袭】附加效果
#【劫营】主动技，大战场。选择1名非城地形的敌将，且消耗5机动力才能发动。你与目标进入白刃战。仅在此次白刃战中，你的兵力变为500，兵种为全骑兵（不计入实际兵力）。每个回合限1次。。小战场进行到 20 回合，自动退出战场，视为战斗失败。
#【魄袭】大战场&小战场，锁定技。你发动<劫营>时，若对方统＜你，则对方前6回合士兵“包围、后退、待机”随机行动。若本次<劫营>胜利，重置你<劫营>的CD，同一回合最多重置2次。

const ACTIVE_EFFECT_ID = 20015
const BATTLE_TURNS_LIMIT = 20

func on_trigger_30004()->bool:
	#获取劫营标记
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	ske.set_war_skill_val(0, 0, ACTIVE_EFFECT_ID)
	# 加入魄袭效果判断
	if bf.loserId == enemy.actorId\
		and SkillHelper.actor_has_skills(actorId, ["魄袭"]):
		var times = ske.get_war_skill_val_int()
		times += 1
		ske.set_war_skill_val(times, 1)
		if times <= 2:
			# HACK 一下，只为了汇报
			ske.skill_name = "魄袭"
			ske.clear_actor_skill_cd(actorId, [20000], [ACTIVE_EFFECT_ID])
			# 汇报到大战场
			ske.war_report()
			# HACK 回来
			ske.skill_name = "劫营"
	return false

func on_trigger_30009()->bool:
	var bf = DataManager.get_current_battle_fight()
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	if bf.turns() <= BATTLE_TURNS_LIMIT:
		return false
	var bu = get_leader_unit(me.actorId)
	if bu == null or bu.disabled:
		return false
	bu.unit_position.x = -5
	var d = War_Character.DialogInfo.new()
	d.text = "敌营有备，不宜久留\n速退！"
	d.actorId = me.actorId
	d.mood = 0
	d.sceneId = 30000
	me.add_dialog_info(d)
	return false

func on_trigger_30003() -> bool:
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	bf.update_extra_formation_setting(
		actorId, ske.skill_name, "场合", {
			"兵种数量": {"骑": 5},
			"分配顺序": ["骑"],
			"禁用兵种转换": 1,
		}
	)

	var prevSoldiers = actor.get_soldiers()
	actor.set_soldiers(500)

	# 修正白兵战数据
	bf.attackerSoldiers = 500

	var recover = bf.get_env_dict("战后兵力")
	recover[str(actorId)] = prevSoldiers
	bf.set_env("战后兵力", recover)

	return false

func on_trigger_30005() -> bool:
	#获取劫营标记
	if ske.get_war_skill_val_int(ACTIVE_EFFECT_ID) <= 0:
		return false
	if not SkillHelper.actor_has_skills(actorId, ["魄袭"]):
		return false
	if enemy.battle_lead >= me.battle_lead:
		return false
	var turns = ske.set_war_buff(enemy.actorId, "混乱", 6)
	var msg = "{0}竟敢孤军直入！\n（因{1}【魄袭】\n（{2}部[混乱]{3}回合".format([
		DataManager.get_actor_honored_title(actorId, enemy.actorId),
		actor.get_name(), enemy.get_name(), turns,
	])
	enemy.attach_free_dialog(msg, 0, 30000)
	return false
