extends Weapon

func _ready():
	$Melee/MeleeShape.disabled = true
	
	firerate = 60/base_firerate
	reload_time = base_reload_time
	empty_reload_time = base_empty_reload_time
	damage = base_damage

	mag_size = base_mag_size
	ammo_count = base_ammo_count
	accuracy = base_accuracy
	concealment = base_concealment
	
	current_mag_size = mag_size
	current_ammo_count = ammo_count

	if (concealment < 8):
		is_weapon_visible = true
	else:
		is_weapon_visible = false

func _process(delta):	
	if (shake_camera):
		Game.player.get_node("Player_camera").offset = Vector2(rand_range(-5,5) * cam_shake_intensity,rand_range(-5,5) * cam_shake_intensity)

func end_shake() -> void:
	shake_camera = false

func shoot() -> void:
	if (current_mag_size > 0 && firerate_timer.time_left <= 0):
		current_mag_size -= 1
		
		shake_camera = true
		get_tree().create_timer(0.1).connect("timeout",self,"end_shake")
		
		fire_sound.play()
		firerate_timer.wait_time = firerate
		firerate_timer.start()
		
		var bullet = bullet_scene.instance()
		bullet.accuracy = self.accuracy
		Game.game_scene.add_child(bullet)
		bullet.global_position = Game.player.get_node("Bullet_origin").global_position	

		var noise = noise_scene.instance()
		noise.radius = 1000
		noise.time = 0.1
		Game.game_scene.add_child(noise)
		noise.global_position = Game.player.global_position

	.shoot()

func reload() -> void:
	if (current_mag_size != mag_size):
		if (current_mag_size > 0 && current_ammo_count > 0):
			var actual_reload_duration = base_reload_time / reload_time 
			Game.player_is_reloading = true
			
			reload_timer.wait_time = reload_time
			reload_timer.start()
			
			anim_player.play("reload",-1,actual_reload_duration)
			print(anim_player.is_playing())
			
			reload_sound.pitch_scale = actual_reload_duration
			reload_sound.play()
		elif (current_mag_size == 0 && current_ammo_count > 0):
			var actual_reload_duration = base_empty_reload_time / empty_reload_time 
			Game.player_is_reloading = true
			
			reload_timer.wait_time = empty_reload_time
			reload_timer.start()
			
			anim_player.play("reload",-1,actual_reload_duration)
			
			reload_empty_sound.pitch_scale = actual_reload_duration
			reload_empty_sound.play()	
		else:
			if (firerate_timer.time_left <= 0):
				fire_dry_sound.play()
				
				firerate_timer.wait_time = 0.5
				firerate_timer.start()	
				
	.reload()

func reload_finish() -> void:
	var needed_bullets: int = mag_size - current_mag_size
	
	if (current_ammo_count < needed_bullets):
		current_mag_size += current_ammo_count
		current_ammo_count -= needed_bullets
		
		var fake_bullets: int = -current_ammo_count
		current_ammo_count += fake_bullets
	else:
		current_ammo_count -= needed_bullets
		current_mag_size = mag_size
		
	Game.player_is_reloading = false
	
	.reload_finish()

func melee() -> void:
	Game.player_is_meleing = true
	
	anim_player.play("melee")
	
	yield(anim_player,"animation_finished")
	
	Game.player_is_meleing = false	
	.melee()
