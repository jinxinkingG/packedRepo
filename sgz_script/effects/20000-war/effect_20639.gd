extends "effect_20000.gd"

# 族连诱发技
#【族连】大战场，诱发技。若你非主将，与你同姓的敌将死亡/俘虏时可以发动。由主将选择是否对你连坐：若选择“是”，你死亡，你方金+1000；若选择“否”，主将经验+500。战争中限1次。

const EFFECT_ID = 20639
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func on_trigger_20027()->bool:
	ske.set_war_skill_val(-1)
	# 目标武将被禁用前
	var wa = DataManager.get_war_actor(ske.actorId)
	if wa == null or wa.disabled:
		return false
	if wa.actor().get_first_name() != actor.get_first_name():
		# 同姓才能触发
		return false
	ske.set_war_skill_val(ske.actorId)
	return false

func on_trigger_20020()->bool:
	# 小战场结束后
	if me == null or me.disabled:
		return false
	# 主将不触发
	if me.get_main_actor_id() == actorId:
		return false
	var bf = DataManager.get_current_battle_fight()
	# 这里跟诈取不同，目标已经挂了，光环技无法发动
	# 只能触发胜方来源武将
	var loser = bf.get_loser()
	if loser == null:
		return false
	if loser.actorId == ske.actorId:
		# 失败方不触发，也没法正常触发
		return false
	var targetActor = ActorHelper.actor(loser.actorId)
	if not targetActor.is_status_dead() and not targetActor.is_status_captured():
		# 死亡或被俘才触发
		return false
	if ske.get_war_skill_val_int(-1, -1, -1) != loser.actorId:
		return false
	return true

func on_trigger_20012()->bool:
	# 计策结束后
	if me == null or me.disabled:
		return false
	# 主将不触发
	if me.get_main_actor_id() == actorId:
		return false
	var se = DataManager.get_current_stratagem_execution()
	# 这里跟诈取不同，目标已经挂了，光环技无法发动
	# 只能触发计策来源武将
	if se.get_action_id(actorId) != ske.actorId:
		return false
	if se.targetId < 0:
		return false
	var targetActor = ActorHelper.actor(se.targetId)
	if not targetActor.is_status_dead() and not targetActor.is_status_captured():
		return false
	if ske.get_war_skill_val_int(-1, -1, -1) != se.targetId:
		return false
	se.skip_redo = 1
	return true

func effect_20639_start() -> void:
	var targetId = ske.get_war_skill_val_int(-1, -1, -1)
	if targetId < 0:
		LoadControl.end_script()
		return
	var msg = "{0} ……\n何苦来哉".format([
		DataManager.get_actor_honored_title(targetId, actorId)
	])
	play_dialog(actorId, msg, 3, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_choice")
	return

func effect_20639_choice() -> void:
	var targetId = ske.get_war_skill_val_int(-1, -1, -1)
	var msg = "{0}力抗我军战败\n是否【{1}】{2}？".format([
		ActorHelper.actor(targetId).get_name(),
		ske.skill_name, actor.get_name(),
	])
	play_dialog(me.get_main_actor_id(), msg, 2, 2001, true)
	return

func on_view_model_2001() -> void:
	wait_for_yesno(FLOW_BASE + "_execute", false, FLOW_BASE + "_spare", false)
	return

func effect_20639_execute() -> void:
	var msg = "兔死狐悲，物伤其类\n{0}必生异心\n左右斩讫报来！".format([
		actor.get_name(),
	])
	play_dialog(me.get_main_actor_id(), msg, 0, 2002)
	return

func on_view_model_2002() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_executed")
	return

func effect_20639_executed() -> void:
	ske.cost_war_cd(99999)
	var wv = me.war_vstate()
	ske.war_execute(me.get_main_actor_id(), actorId)
	var gold = ske.change_wv_gold(1000, wv)
	ske.war_report()
	map.draw_actors()
	var msg = "倾心相托，竟不能容！\n（{0}死亡\n（{1}军金 +{2}".format([
		actor.get_name(), wv.get_lord_name(), gold,
	])
	play_dialog(actorId, msg, 3, 2990)
	return

func effect_20639_spare() -> void:
	var targetId = ske.get_war_skill_val_int(-1, -1, -1)
	ske.cost_war_cd(99999)
	var val = ske.change_actor_exp(me.get_main_actor_id(), 500)
	var msg = "{0}忠勤清慎，非贰臣也\n望以{1}为戒\n（{2}经验 +{3}".format([
		DataManager.get_actor_honored_title(actorId, me.get_main_actor_id()),
		ActorHelper.actor(targetId).get_name(),
		me.get_leader().get_name(), val,
	])
	play_dialog(me.get_main_actor_id(), msg, 2, 2990)
	return

