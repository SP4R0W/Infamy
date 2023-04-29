extends Node2D
class_name Weapon

var base_firerate: float = 1.0
var base_reload_time: float = 1.0
var base_empty_reload_time: float = 1.0
var base_damage: float = 0.1
export (float, 0.1,5,0.05) var cam_shake_intensity = 0.1

var base_mag_size: int = 1
var base_ammo_count: int = 1
var base_accuracy: int = 0
var base_concealment: int = 0

export var weapon_position = Vector2(0,0)

export (String, "light", "heavy") var animation = "light"

onready var sprite: Sprite = $Sprite
onready var melee_shape: CollisionShape2D = $Melee/MeleeShape
onready var anim_player: AnimationPlayer = $AnimationPlayer

onready var firerate_timer: Timer = $Firerate
onready var reload_timer: Timer = $Reload_timer

onready var fire_sound: AudioStreamPlayer = $Fire
onready var silenced_sound: AudioStreamPlayer = $Silenced
onready var fire_dry_sound: AudioStreamPlayer  = $Fire_dry
onready var reload_sound: AudioStreamPlayer  = $Reload_sound
onready var reload_empty_sound: AudioStreamPlayer  = $Reload_empty

var shake_camera: bool = false

var firerate: float
var reload_time: float
var empty_reload_time: float
var damage: float

var mag_size: int
var ammo_count: int
var accuracy: int
var concealment: int

var type: String

var is_weapon_visible: bool = true
var current_mag_size: int
var current_ammo_count: int

var is_weapon_suppresed: bool = false

func shoot():
	if (current_mag_size > 0 && firerate_timer.time_left <= 0 && !Game.player_is_reloading):

		if (!Game.is_bulletstorm_active):
			current_mag_size -= 1

		shake_camera = true
		get_tree().create_timer(0.1).connect("timeout",self,"end_shake")

		firerate_timer.wait_time = firerate
		firerate_timer.start()

		var bullet = Game.scene_objects["plr_bullet"].instance()
		bullet.accuracy = self.accuracy
		bullet.damage = damage
		bullet.type = type
		Game.game_scene.add_child(bullet)
		bullet.global_position = Game.player.get_node("Bullet_origin").global_position

		if (!is_weapon_suppresed):
			var noise = Game.scene_objects["alert"].instance()

			noise.radius = 4000
			noise.time = 0.1
			noise.global_position = Game.player.global_position

			Game.game_scene.call_deferred("add_child",noise)

			noise.start()

			fire_sound.play()
		else:
			silenced_sound.play()
	elif (current_mag_size == 0 && !Game.player_is_reloading && firerate_timer.time_left <= 0):
		reload()


func reload():
	if (current_mag_size != mag_size && !Game.player_is_reloading):
		var actual_reload_duration

		if (current_mag_size > 0 && current_ammo_count > 0):
			actual_reload_duration = base_reload_time / reload_time

			reload_timer.wait_time = reload_time
		elif (current_mag_size == 0 && current_ammo_count > 0):
			actual_reload_duration = base_empty_reload_time / empty_reload_time

			reload_timer.wait_time = empty_reload_time
		else:
			if (firerate_timer.time_left <= 0):
				fire_dry_sound.play()

				firerate_timer.wait_time = 0.5
				firerate_timer.start()
				return

			return

		if (Game.desperado_active):
			actual_reload_duration *= 0.85
			reload_timer.wait_time *= 0.85
		elif (Game.locknload_active):
			actual_reload_duration *= 0.5
			reload_timer.wait_time *= 0.5
		elif (Game.get_skill("commando",2,3) == "basic" && type == "shotgun"):
			actual_reload_duration *= 0.85
			reload_timer.wait_time *= 0.85

		Game.player_is_reloading = true

		reload_timer.start()

		if (actual_reload_duration == null):
			actual_reload_duration = 1

		anim_player.play("reload",-1,actual_reload_duration)

		reload_sound.pitch_scale = actual_reload_duration
		reload_sound.play()

func reload_finish():
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

func melee():
	$Swing.play()

	Game.player_is_meleing = true

	anim_player.play("melee")

func _process(delta):
	if (shake_camera):
		# Camera shake
		Game.player.get_node("Player_camera").offset = Vector2(rand_range(-5,5) * cam_shake_intensity,rand_range(-5,5) * cam_shake_intensity)

func end_shake() -> void:
	shake_camera = false

func _on_Firerate_timeout():
	if (current_mag_size == 0 && Savedata.player_settings["auto_reload"]):
		if ((Game.player_is_running && Game.get_skill("engineer",3,3) == "upgraded") || !Game.player_is_running):
			reload()

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "melee"):
		Game.player_is_meleing = false
