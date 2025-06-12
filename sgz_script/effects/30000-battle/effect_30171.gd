extends "effect_30000.gd"

#远伏效果
#【远伏】大战场，锁定技。你被攻击时，若对手在大战场与你不相邻，白刃战布阵后，对手损失10%兵力。每个回合限1次。

const EFFECT_ID = 30171
const FLOW_BASE = "effect_" + str(EFFECT_ID)

func _init() -> void:
	FlowManager.bind_import_flow(FLOW_BASE + "_start", self)
	FlowManager.bind_import_flow(FLOW_BASE + "_AI_start", self)

func _input_key(delta:float):
	match LoadControl.get_view_model():
		2000:
			wait_for_skill_result_confirmation("")
	return

func effect_30171_AI_start():
	return effect_30171_start()

func effect_30171_start():
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()

	ske.cost_war_cd(1)

	for bu in DataManager.battle_units:
		if bu == null or bu.disabled:
			continue
		if bu.leaderId != attacker.actorId or bu.get_unit_type() == "将":
			continue
		bu.set_hp(bu.get_hp() * 0.9)
	ske.append_message("损兵10%", attacker.actorId)
	ske.war_report()

	var msg = "{0}劳师远来\n岂知我设伏久矣!\n（{1}损兵10%".format([
		DataManager.get_actor_naughty_title(attacker.actorId, ske.skill_actorId),
		attacker.get_name(),
	])
	SceneManager.show_confirm_dialog(msg, ske.skill_actorId, 0)
	LoadControl.set_view_model(2000)
	return

func check_trigger_correct()->bool:
	var ske = SkillHelper.read_skill_effectinfo()
	var bf = DataManager.get_current_battle_fight()
	var attacker = bf.get_attacker()
	var defender = bf.get_defender()
	if defender == null:
		return false
	if defender.actorId != ske.skill_actorId:
		return false
	var disv = attacker.position - defender.position
	if abs(disv.x) + abs(disv.y) == 1:
		return false
	return true
