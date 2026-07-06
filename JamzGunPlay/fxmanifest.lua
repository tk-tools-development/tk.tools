fx_version 'cerulean'
game 'gta5'

description 'Jamz GunPlay - Tarkov-style Movement Inertia System'
author 'Jamz'
lua54 'yes'

shared_script 'config.lua'

shared_script '@ox_lib/init.lua'

escrow_ignore {
  'config.lua'
}


server_scripts {
    'server/smoke_effect_server.lua',
    'server/upwards_shooting_server.lua',
    'server/suppression_server.lua',
    'server/breath_condensation_server.lua',
}

client_scripts {
    'client/gunplay_frame_cache.lua',
    'client/inertia_client.lua',
    'client/disable_combat_roll_client.lua',
    'client/disable_spam_punch_client.lua',
    'client/disable_combat_walk_client.lua',
    'client/shoulder_swap_client.lua',
    'client/persistent_flashlight_client.lua',
    'client/suppression_client.lua',
    'client/bullet_casings_client.lua',
    'client/upwards_shooting_client.lua',
    'client/hipfire_client.lua',
    'client/smoke_effect_client.lua',
    'client/heated_barrels.lua',
    'client/firing_modes.lua',
    'client/sprint_aim_client.lua',
    'client/ammo_display_client.lua',
    'client/weapon_jamming_client.lua',
    'client/recoil_client.lua',
    'client/barrel_smoke_client.lua',
    'client/gore_client.lua',
    'client/anti_third_person_aim_glitch_client.lua',
    'client/slow_walk_client.lua',
    'client/no_reticle_client.lua',
    'client/breath_condensation_client.lua',
    'client/heavy_weapon_movement_client.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/gore_overlay.html',
    'html/gore_overlay.js',
    'html/style.css',
    'html/script.js',
    'html/vignette.png',
    'html/ringing.mp3',
    'html/ringing2.mp3',
    'html/muffled.mp3',
    'html/crack1.mp3',
    'html/crack2.mp3',
    'html/crack3.mp3',
    'html/crack4.mp3',
    'html/crack5.mp3',
    'html/crack6.mp3',
    'html/crack7.mp3',
    'html/crack8.mp3',
    'html/casing-sfx/single-1.mp3',
    'html/casing-sfx/single-2.mp3',
    'html/casing-sfx/single-3.mp3',
    'html/casing-sfx/single-4.mp3',
    'html/casing-sfx/single-5.mp3',
    'html/casing-sfx/single-6.mp3',
    'html/casing-sfx/single-7.mp3',
    'html/casing-sfx/single-8.mp3',
    'html/casing-sfx/single-9.mp3',
    'html/casing-sfx/single-10.mp3',
    'html/casing-sfx/single-11.mp3',
    'html/casing-sfx/single-12.mp3',
    'html/casing-sfx/single-13.mp3',
    'html/casing-sfx/single-14.mp3',
    'html/casing-sfx/single-15.mp3',
    'html/casing-sfx/single-16.mp3',
    'html/casing-sfx/single-17.mp3',
    'html/casing-sfx/single-18.mp3',
    'html/casing-sfx/single-19.mp3',
    'html/casing-sfx/single-20.mp3',
    'html/casing-sfx/single-21.mp3',
    'html/casing-sfx/single-22.mp3',
    'html/casing-sfx/single-23.mp3',
    'html/casing-sfx/single-24.mp3',
    'html/casing-sfx/single-25.mp3',
    'html/casing-sfx/single-26.mp3',
    'html/casing-sfx/single-27.mp3',
    'html/casing-sfx/single-28.mp3',
    'html/casing-sfx/single-29.mp3',
    'html/casing-sfx/single-30.mp3',
    'html/casing-sfx/single-31.mp3',
    'html/casing-sfx/single-32.mp3',
    -- Weapon meta files (main folder)
    'metas/weapons.meta',
    'metas/weaponanimations.meta',
    'metas/weaponarchetypes.meta',
    'metas/weaponhominglauncher.meta',
    -- Weapon meta files (DLCS folder)
    'metas/EXTRAS/weapons.meta',
    'metas/EXTRAS/weapon_ceramicpistol.meta',
    'metas/EXTRAS/weapon_combatshotgun.meta',
    'metas/EXTRAS/weapon_gadgetpistol.meta',
    'metas/EXTRAS/weapon_militaryrifle.meta',
    'metas/EXTRAS/weapon_navyrevolver.meta',
    'metas/EXTRAS/weapon_pistolxm3_1.meta',
    'metas/EXTRAS/weapon_pistolxm3.meta',
    'metas/EXTRAS/weapon_precisionrifle.meta',
    'metas/EXTRAS/weapon_tacticalrifle.meta',
    'metas/EXTRAS/weapon_tecpistol.meta',
    'metas/EXTRAS/weaponautoshotgun.meta',
    'metas/EXTRAS/weaponbullpuprifle.meta',
    'metas/EXTRAS/weaponcombatpdw.meta',
    'metas/EXTRAS/weaponcompactlauncher.meta',
    'metas/EXTRAS/weaponcompactrifle.meta',
    'metas/EXTRAS/weapondbshotgun.meta',
    'metas/EXTRAS/weapongusenberg.meta',
    'metas/EXTRAS/weaponheavypistol.meta',
    'metas/EXTRAS/weaponheavyshotgun.meta',
    'metas/EXTRAS/weaponmachinepistol.meta',
    'metas/EXTRAS/weaponmarksmanpistol.meta',
    'metas/EXTRAS/weaponmarksmanrifle.meta',
    'metas/EXTRAS/weaponminismg.meta',
    'metas/EXTRAS/weaponmusket.meta',
    'metas/EXTRAS/weaponrailgun.meta',
    'metas/EXTRAS/weaponrevolver.meta',
    'metas/EXTRAS/weapons_assaultrifle_mk2.meta',
    'metas/EXTRAS/weapons_bullpuprifle_mk2.meta',
    'metas/EXTRAS/weapons_carbinerifle_mk2.meta',
    'metas/EXTRAS/weapons_combatmg_mk2.meta',
    'metas/EXTRAS/weapons_doubleaction.meta',
    'metas/EXTRAS/weapons_emplauncher.meta',
    'metas/EXTRAS/weapons_heavyrifle.meta',
    'metas/EXTRAS/weapons_heavysniper_mk2.meta',
    'metas/EXTRAS/weapons_marksmanrifle_mk2.meta',
    'metas/EXTRAS/weapons_pistol_mk2.meta',
    'metas/EXTRAS/weapons_pumpshotgun_mk2.meta',
    'metas/EXTRAS/weapons_revolver_mk2.meta',
    'metas/EXTRAS/weapons_smg_mk2.meta',
    'metas/EXTRAS/weapons_snspistol_mk2.meta',
    'metas/EXTRAS/weapons_spacerangers.meta',
    'metas/EXTRAS/weapons_specialcarbine_mk2.meta',
    'metas/EXTRAS/weaponsnspistol.meta',
    'metas/EXTRAS/weaponspecialcarbine.meta',
    'metas/EXTRAS/weaponturretinsurgent.meta',
    'metas/EXTRAS/weaponturrettechnical.meta',
    'metas/EXTRAS/weaponturretvalkyrie.meta',
    'metas/EXTRAS/weaponvehiclesavage.meta',
    'metas/EXTRAS/weaponvintagepistol.meta',
    -- Weapon animation files (subfolders)
    'metas/LMG/weaponanimations.meta',
    'metas/ANIM/weaponanimations.meta',
    'metas/TEC/weaponanimations.meta',
    'metas/ANIM2/weaponanimations.meta',
}

-- Weapon information files (weapons.meta and individual weapon files)
-- Main weapons file (load first)
data_file 'WEAPONINFO_FILE_PATCH' 'metas/weapons.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/weaponarchetypes.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/weaponhominglauncher.meta'

-- DLC weapons file (load after main)
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons.meta'

-- Individual DLC weapon files
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_ceramicpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_combatshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_gadgetpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_militaryrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_navyrevolver.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_pistolxm3_1.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_pistolxm3.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_precisionrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_tacticalrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapon_tecpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponautoshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponbullpuprifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponcombatpdw.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponcompactlauncher.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponcompactrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapondbshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapongusenberg.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponheavypistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponheavyshotgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponmachinepistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponmarksmanpistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponmarksmanrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponminismg.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponmusket.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponrailgun.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponrevolver.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_assaultrifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_bullpuprifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_carbinerifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_combatmg_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_doubleaction.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_emplauncher.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_heavyrifle.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_heavysniper_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_marksmanrifle_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_pistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_pumpshotgun_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_revolver_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_smg_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_snspistol_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_spacerangers.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weapons_specialcarbine_mk2.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponsnspistol.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponspecialcarbine.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponturretinsurgent.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponturrettechnical.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponturretvalkyrie.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponvehiclesavage.meta'
data_file 'WEAPONINFO_FILE_PATCH' 'metas/EXTRAS/weaponvintagepistol.meta'

-- Weapon animations files
data_file 'WEAPON_ANIMATIONS_FILE_PATCH' 'metas/weaponanimations.meta'
data_file 'WEAPON_ANIMATIONS_FILE_PATCH' 'metas/LMG_MK2/weaponanimations.meta'
data_file 'WEAPON_ANIMATIONS_FILE_PATCH' 'metas/SPACE/weaponanimations.meta'
data_file 'WEAPON_ANIMATIONS_FILE_PATCH' 'metas/TEC_PISTOL/weaponanimations.meta'
data_file 'WEAPON_ANIMATIONS_FILE_PATCH' 'metas/TOMMY/weaponanimations.meta'


data_file 'DLC_ITYP_REQUEST' 'stream/heated_barrels.ytyp'

-- Gore --
data_file 'DLC_ITYP_REQUEST' 'stream/blood_stains.ytyp'

data_file 'DLC_ITYP_REQUEST' 'stream/peddamage.xml'
dependency '/assetpacks'