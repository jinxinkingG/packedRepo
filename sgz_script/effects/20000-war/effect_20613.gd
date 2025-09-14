extends "effect_20000.gd"

#逢亮效果3实现，同阵营出战
#【逢亮】大战场，转换技·规则技。满足以下条件之一时，你永久转为<阳>面，且忠变为与诸葛亮相同：①战争中你转移阵营，当前阵营不是你的战争初始势力，且队内有忠>90的诸葛亮；②你与诸葛亮同阵营出战，超过3次。


const CALLBACK_SCRIPT = "effects/20000-war/effect_20613.gd"

const ZHIJI_SKILL_NAME = "志继"
const ZHIJI_EFFECT_ID = 20213

const DIALOGS = [
	[
		["<NICK>，为将者，何为要？", 1],
		["治心为要，持重而通变", 0],
		["诚当然也\n应变将略，岂在成规", 1],
	],
	[
		["<NICK>，为帅者，何为要？", 1],
		["明势为要，谋局以虑远", 0],
		["诚如是也\n欲夺天下之机，非在一时一地", 1]
	],
	[
		["<NICK>，为臣者，何为要？", 1],
		["立节为要，明志匡社稷", 0],
		["<NICK>麒麟之才，英杰意气\n继吾者，舍<NICK>为谁？\n当传平生之学", 1],
		["<NICK>之志，即为吾志！\n讨贼兴汉，<SHORT>何惜一身！", 0],
		["", -1, "done"],
	],
]

func on_trigger_20013() -> bool:
	var actor = me.actor()
	if actor.is_face_positive():
		return false
	var sleepingDragon = me.war_vstate().get_war_actor(StaticManager.ACTOR_ID_ZHUGELIANG)
	if sleepingDragon == null or sleepingDragon.disabled or not sleepingDragon.has_position():
		return false
	ske.cost_war_cd(99999)
	var times = ske.affair_get_skill_val_int()
	ske.affair_set_skill_val(times + 1)

	if times >= DIALOGS.size():
		return false

	for setting in DIALOGS[times]:
		var speaker = actorId
		var targetId = sleepingDragon.actorId
		if setting[1] == 1:
			speaker = sleepingDragon.actorId
			targetId = actorId
		elif setting[1] == -1:
			speaker = -1
			targetId = actorId
		var msg = format_message(setting[0], speaker, targetId)
		var d = me.attach_free_dialog(msg, 2, 20000, speaker)
		if setting.size() == 3:
			d.callback_script = CALLBACK_SCRIPT
			d.callback_method = setting[2]
	return false

func format_message(msg:String, from:int, to:int) -> String:
	msg = msg.replace("<NICK>", DataManager.get_actor_honored_title(to, from))
	msg = msg.replace("<SHORT>", actor.get_short_name())
	msg = msg.replace("<NAME>", actor.get_name())
	return msg

func done():
	me = DataManager.get_war_actor(actorId)
	if me == null or me.disabled:
		return
	var sleepingDragon = DataManager.get_war_actor(StaticManager.ACTOR_ID_ZHUGELIANG)
	if sleepingDragon == null or sleepingDragon.disabled or not sleepingDragon.has_position():
		return

	# 转面
	var actor = me.actor()
	actor.set_face(true)
	actor.set_loyalty(min(99, sleepingDragon.actor().get_loyalty()))
	
	if not SkillHelper.actor_has_skills(me.actorId, [ZHIJI_SKILL_NAME]):
		return false

	var dic = {
		"current_actor": me.actorId,
		"effect_id": ZHIJI_EFFECT_ID,
		"triggerId": -1,
		"skill_name": ZHIJI_SKILL_NAME,
		"skill_actor": me.actorId,
	}
	var st = SkillTriggerInfo.new()
	st.induce_dialog = ""
	st.actorId = actorId
	st.triggerId = -1
	st.lock_effects = [dic]
	st.induce_effects = []
	st.next_flow = "player_ready"
	if DataManager.get_scene_actor_control(actorId) < 0:
		st.next_flow = "AI_before_ready"
	SkillHelper.add_skill_triggerinfo(st)

	return
