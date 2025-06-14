extends "effect_20000.gd"

# 文涌主动技
#【文涌】大战场，限定技。消耗10点机动力发动：你随军做诗，令众人都惊叹你的诗赋散文，己方全体武将的机动力上限+1，且获得的组队经验+5%

const EFFECT_ID = 20567
const FLOW_BASE = "effect_" + str(EFFECT_ID)

const POEMS = [
	"潛鱗在淵，歸鴈載軒。\n苟非鴻鵰，孰能飛飜？",
	"君子信誓，不遷于時。\n及子同寮，生死固之。",
	"橫此大江，淹彼南汜。\n我思弗及，載坐載起。",
	"晨風夕逝，託與之期。\n瞻仰王室，慨其永歎。",
	"延陵有作，僑肸是與。\n先民遺跡，來世之矩。",
	"江漢有卷，允來厥休。\n二邦若否，職汝之由。",
	"百鳥何繽翻，振翼羣相追。\n投網引潛魚，强弩下髙飛。",
	"南登霸陵岸，迴首望長安。\n悟彼下泉人，喟然傷心肝。",
	"生為百夫雄，死為壯士規。\n黃鳥作悲詩，至今聲不虧。",
	"拓地三千里，往返速若飛。\n歌舞入鄴城，所願獲無違。",
	"身服干戈事，豈得念所私。\n即戎有授命，茲理不可違。",
	"連舫踰萬艘，帶甲千萬人。\n率彼東南路，將定一舉勳。",
]

const COST_AP = 10

func effect_20567_start() -> void:
	if not assert_action_point(actorId, COST_AP):
		return
	var wf = DataManager.get_current_war_fight()
	if wf.get_env_int(ske.skill_name) > 0:
		var msg = "文之道，贵精贵正\n执着反复，有何益哉"
		play_dialog(actorId, msg, 2, 2999)
		return
	var poem = POEMS[randi() % POEMS.size()]
	var msg = "… …\n" + poem + "\n… …"
	wf.set_env(ske.skill_name, 1)
	play_dialog(actorId, msg, 2, 2000)
	return

func on_view_model_2000() -> void:
	wait_for_skill_result_confirmation(FLOW_BASE + "_2")
	return

func effect_20567_2() -> void:
	var respondId = -1
	var maxPolitics = -1

	ske.set_actor_extra_ap_limit(actorId, 1)
	for wa in me.get_teammates(false):
		ske.set_actor_extra_ap_limit(wa.actorId, 1)
		var pol = wa.actor().get_politics()
		if pol > maxPolitics:
			maxPolitics = pol
			respondId = wa.actorId
	ske.add_team_exp_rate(0.05)
	ske.cost_ap(COST_AP, true)
	ske.cost_war_cd(99999)
	ske.war_report()

	var msg = "\n（{0}机动力 -{1}，现为 {2}\n（全军机动力上限 +1\n（团队经验 +5%".format([
		actor.get_name(), COST_AP, me.action_point,
	])
	if respondId >= 0:
		var response = "{0}令德，何道不洽！".format([
			DataManager.get_actor_honored_title(actorId, respondId),
		])
		if actorId != StaticManager.ACTOR_ID_WANGCAN:
			response = "此仲宣诗也，思之慨然！"
		msg = response + msg

	play_dialog(respondId, msg, 1, 2999)
	return
