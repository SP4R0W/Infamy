extends Panel

var preplanning_info: Dictionary = {
	"bank":{
		"max_favors":10,
		"assets": {
			"medic":{
				"max":1,
				"price":2,
				"name":"Medic Bag",
				"desc":"A small bag containing 2 first aid kits, ready to be taken for later or used at spot.",
				"locations":[
					{
						"name":"Kitchen",
						"id":"medic1",
					},
					{
						"name":"Security Room",
						"id":"medic2",
					}
				]
			},
			"ammo":{
				"max":1,
				"price":2,
				"name":"Ammo Bag",
				"desc":"A small bag containing 2 ammo kits, ready to be taken for later or used at spot.",
				"locations":[
					{
						"name":"Rest Room",
						"id":"ammo1",
					},
					{
						"name":"Vault Room",
						"id":"ammo2",
					}
				]
			},
			"cables":{
				"max":1,
				"price":2,
				"name":"Extra Handcuffs",
				"desc":"12 extra handcuffs for when you need to control a large crowd.",
				"locations":[
					{
						"name":"Lobby",
						"id":"cables1",
					},
					{
						"name":"Back Room",
						"id":"cables2",
					}
				]
			},
			"bodys":{
				"max":1,
				"price":2,
				"name":"Body Bag",
				"desc":"Extra body bags when things go messy.",
				"locations":[
					{
						"name":"Changing Room",
						"id":"bodies1",
					},
					{
						"name":"Outside",
						"id":"bodies2",
					}
				]
			},
			"delay":{
				"max":1,
				"price":4,
				"name":"Delayed Police Response",
				"desc":"If things go wrong, the police will arrive later than usual.",
			},
			"van":{
				"max":1,
				"price":8,
				"name":"Closer Van",
				"desc":"A van will wait for you at the back of the bank.",
			}
		},
	}
}

var remaining_favors: int = 0
var current_item: String = ""

func _ready():
	remaining_favors = preplanning_info[Game.level]["max_favors"]
	
func show():
	$Asset_desc/Title.text = "Select an asset"
	for child in $Asset_desc.get_children():
		if (child.name == "Title"):
			continue
			
		child.hide()
		
	$Asset_info/Favours.text = "Available favours: " + str(remaining_favors) + "/" + str(preplanning_info[Game.level]["max_favors"])
		
	var assets: Dictionary = preplanning_info[Game.level]["assets"]
	for asset in assets.keys():
		get_node("Asset_info/Asset_list/HBoxContainer/"+asset).show()
	
	.show()

func show_asset(asset: String) -> void:
	current_item = asset
	
	var asset_info: Dictionary = preplanning_info[Game.level]["assets"][asset]
	
	$Asset_desc/Title.text = asset_info["name"]
	
	$Asset_desc/Desc.show()
	$Asset_desc/Desc.text = asset_info["desc"]
	
	$Asset_desc/Price.show()
	$Asset_desc/Price.text = "Price: " + str(asset_info["price"]) + " Favours"
	
	if (asset_info.has("locations")):
		var counts = 0
		
		for item in Game.map_assets:
			if (item.find(current_item) != -1):
				counts += 1
		
		$Asset_desc/Max.text = "Used: " + str(counts) + "/" + str(asset_info["max"])
		$Asset_desc/Max.show()
		$Asset_desc/Button.hide()
	
		$Asset_desc/Locations.show()
		$Asset_desc/Locations.clear()
		
		for item in asset_info["locations"]:
			if (item["id"] in Game.map_assets):
				$Asset_desc/Locations.add_item(item["name"] + "- Remove")
			else:
				$Asset_desc/Locations.add_item(item["name"] + "- Buy")
	else:
		$Asset_desc/Max.hide()
		
		$Asset_desc/Locations.hide()
		$Asset_desc/Button.show()
		
		if (asset in Game.map_assets):
			$Asset_desc/Button.text = "Remove"
		else:
			$Asset_desc/Button.text = "Buy"
		
func _on_medic_pressed():
	show_asset("medic")
	
func _on_cables_pressed():
	show_asset("cables")

func _on_bodys_pressed():
	show_asset("bodys")
	
func _on_delay_pressed():
	show_asset("delay")

func _on_ammo_pressed():
	show_asset("ammo")

func _on_van_pressed():
	show_asset("van")
	
func _on_Locations_item_activated(index):
	var price = preplanning_info[Game.level]["assets"][current_item]["price"]
	var max_uses = preplanning_info[Game.level]["assets"][current_item]["max"]
	
	var asset = preplanning_info[Game.level]["assets"][current_item]["locations"][index]
	
	var counts = 0
	
	if (asset["id"] in Game.map_assets):
		Game.map_assets.erase(asset["id"])
		
		for item in Game.map_assets:
			if (item.find(current_item) != -1):
				counts += 1
		
		$Asset_desc/Max.text = "Used: " + str(counts) + "/" + str(max_uses)
		
		remaining_favors += price
		$Asset_desc/Locations.set_item_text(index,asset["name"] + "- Buy")
	else:
		for item in Game.map_assets:
			if (item.find(current_item) != -1):
				counts += 1
				
		if (counts < max_uses && remaining_favors >= price):
			$Asset_desc/Max.text = "Used: " + str(counts + 1) + "/" + str(max_uses)
			remaining_favors -= price
			Game.map_assets.append(asset["id"])
			$Asset_desc/Locations.set_item_text(index,asset["name"] + "- Remove")
			
	$Asset_info/Favours.text = "Available favours: " + str(remaining_favors) + "/" + str(preplanning_info[Game.level]["max_favors"])	
		
func _on_Button_pressed():
	var price = preplanning_info[Game.level]["assets"][current_item]["price"]
	
	if (current_item in Game.map_assets):
		remaining_favors += price
		Game.map_assets.erase(current_item)
		$Asset_desc/Button.text = "Buy"
	else:
		if (remaining_favors >= price):
			remaining_favors -= price
			Game.map_assets.append(current_item)
			$Asset_desc/Button.text = "Remove"
			
	$Asset_info/Favours.text = "Available favours: " + str(remaining_favors) + "/" + str(preplanning_info[Game.level]["max_favors"])	
