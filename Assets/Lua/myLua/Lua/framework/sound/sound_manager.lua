local event_dispatcher = require("framework.event.event_dispatcher")
local res_loader = require("framework.utils.loader.res_loader")
local sound_manager = class("sound_manager", event_dispatcher)

local kStoreKey = {
	MUSIC_PLAY 		= "_key_music_play";
	MUSIC_VOLUME 	= "_key_music_volume";

	EFFECT_PLAY	 	= "_key_effect_play";
	EFFECT_VOLUME 	= "_key_effect_volume";
}

local SoundType = const.sound_type

local CommonConfig = {
	[SoundType.DEFAULT_BG_MUSIC] 		= { abName = "common/audio/bgm"; 		assetName = "bgm_game"; 		};
	[SoundType.CLICK_EFFECT] 			= { abName = "common/audio/effect"; 	assetName = "button_click"; 	};
}


function sound_manager:ctor()
	self.m_isPlayMusic = true
	self.m_musicVolume = 1
	self.m_isPlayEffect = true
	self.m_effectVolume = 1
	self.m_musicAudio = nil

	self.m_resloader = res_loader.new()
	self.m_audio_info_map = {}
	self:init()
end

function sound_manager:init()
	self.m_game_node =  LuaFramework.GameWorld.Inst.gameObject;
	self.m_musicAudio = self.m_game_node:AddComponent(typeof(UnityEngine.AudioSource))
	self.m_musicAudio.loop = true

	self.m_audioStore = utils.dict.new("sound_setting", true)
	
	self.m_isPlayMusic = self.m_audioStore:get_bool(kStoreKey.MUSIC_PLAY, true)
	self.m_isPlayEffect = self.m_audioStore:get_bool(kStoreKey.EFFECT_PLAY, true)
	self.m_musicVolume = self.m_audioStore:get_number(kStoreKey.MUSIC_VOLUME, 1)
	self.m_effectVolume = self.m_audioStore:get_number(kStoreKey.EFFECT_VOLUME, 1)
end

function sound_manager:setMusicOpen( open )
	self.m_isPlayMusic = open
	self.m_audioStore:set_bool(kStoreKey.MUSIC_PLAY, open)

	if open then
		self:resumeMusic()
	else
		self:stopMusic()
	end
end

function sound_manager:setEffectOpen(open)
	self.m_isPlayEffect = open
	self.m_audioStore:set_bool(kStoreKey.EFFECT_PLAY, open)
end

function sound_manager:setMusicVolume( volume )
	self.m_musicVolume = volume
	self.m_audioStore:set_number(kStoreKey.MUSIC_VOLUME, volume)
	self.m_musicAudio.volume = volume
end

function sound_manager:setEffectVolume( volume )
	self.m_effectVolume = volume
	self.m_audioStore:set_number(kStoreKey.EFFECT_VOLUME, volume)
end

function sound_manager:stopMusic()
	self.m_musicAudio:Stop()
end

function sound_manager:resumeMusic()
	self.m_musicAudio:Play()
end

function sound_manager:stopAll()
	self:stopMusic()
	self:stopEffects()
end

function sound_manager:stopEffects()
	self.m_effectAudio:Stop()
end

function sound_manager:playDefaultMusic()
	self:playSoundByType(SoundType.DEFAULT_BG_MUSIC)
end

function sound_manager:playClickEffect()
	self:playSoundByType(SoundType.CLICK_EFFECT)
end

function sound_manager:playSoundByType( soundType )
	local item = CommonConfig[soundType]
	if item == nil then
		log.e("cant't find the sound res by type:", tostring(soundType))
		return
	end

	if soundType < SoundType.BG_BEGIN then
		self:playEffect(item.abName, item.assetName)
	else
		self:playBGMusic(item.abName, item.assetName)
	end
end

function sound_manager:playBGMusic( abName, assetName, ui_base)
	if not self.m_isPlayMusic then return end
	local owner = owner == nil and self or owner
	self.m_bgInfo = { abName = abName, assetName = assetName }

	local loader = ui_base == nil and self.m_resloader or ui_base:get_resloader()

    local clip = loader:load_asset(abName, assetName)
    self.m_musicAudio.clip = clip
    self.m_musicAudio:Play()
end

function sound_manager:playEffect( abName, assetName, ui_base)
	if not self.m_isPlayEffect then return end

	local owner = owner == nil and self or owner

	local loader = ui_base == nil and self.m_resloader or ui_base:get_resloader()
	local clip = loader:load_asset(abName, assetName)
	if clip == nil or tolua.isnull(clip) then
		g_log.e(string.format("can't load sound asset[%s|%s]", abName, assetName))
		return
	end

	self.m_musicAudio:PlayOneShot(clip, self.m_effectVolume)
end

return sound_manager