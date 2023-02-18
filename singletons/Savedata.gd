extends Node

var player_loadouts: Dictionary = {
	1:{"primary":"UZI",
	"attachments_primary":{
		"barrel":"suppressor1",
		"sight":"",
		"magazine":"short_uzi",
		"stock":""
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"suppressor2",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"armor":"Suit",
	"equipment1":"ECM",
	"equipment2":"C4"},
	
	2:{"primary":"UZI",
	"attachments_primary":{
		"barrel":"compensator3",
		"sight":"acog",
		"magazine":"extended_uzi",
		"stock":"stock_uzi"
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"compensator3",
		"sight":"",
		"magazine":"extended_m9",
		"stock":""
	},
	"armor":"Full",
	"equipment1":"Medic Bag",
	"equipment2":"Ammo Bag"},
	
	3:{"primary":"UZI",
	"attachments_primary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"armor":"Suit",
	"equipment1":"ECM",
	"equipment2":"C4"},
}

var owned_attachments: Dictionary = {
	"suppressor1":0,
	"suppressor2":0,
	"suppressor3":0,
	"compensator1":0,
	"compensator2":0,
	"compensator3":0,
	"reflex":0,
	"holo":0,
	"acog":0,
	"extended_m9":0,
	"extended_uzi":0,
	"short_uzi":0,
	"stock_uzi":0,
}

var owned_weapons: Array = ["UZI","M9"]

var music_volume: float = -10
var sfx_volume: float = 0
