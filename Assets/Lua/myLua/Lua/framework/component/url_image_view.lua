--[[
	使用方法：
	一、直接没有现成的 节点需要动态创建节点 
		local urlImage = url_image_view:create( parent ) 将创建一个动态节点，次创建的节点需要自己设置大小scale等属性
		urlImage:set_url("xxx.png")

	二、直接基于界面现有的节点扩展 url_image_view 功能
		local urlImage =  url_image_view.extend( gameObject )
		urlImage:set_url("xxx.png")
--]]

local ui_base = require("framework.mvp.ui_base")
local url_image_view = class("url_image_view", ui_base)

local WWW = UnityEngine.WWW;
local kTimeOut = 10
local kMaxTry = 10

function url_image_view:create( parent, ...)
	return url_image_view.extend(function(instance)
		local gameObject = UnityEngine.GameObject.New("url_image_view")
		local transform = gameObject:AddComponent(typeof(UnityEngine.RectTransform))
		gameObject:AddComponent(typeof(UnityEngine.UI.RawImage))
		transform:SetParent(parent)
		transform.localScale = Vector3(1, 1, 1)
		return gameObject  
	end, ...)
end

function url_image_view:ctor()
	self.m_url = nil
	self.m_curCo = nil
	self.m_tryTimes = 0

	self:init_core()
	ui_base.ctor(self)
end

function url_image_view:init_core()
	self.m_rawImage = self.m_uiroot:GetComponent(typeof(UnityEngine.UI.RawImage))
	if nil == self.m_rawImage then
		g_log.e("can't find  RawImage Component from gameObject!");
	end
end

local function _onInitTexture(self, url, texture )
	if url == self.m_url and not tolua.isnull(self.m_rawImage) then
		self.m_rawImage.texture = texture
		self.m_rawImage.color = UnityEngine.Color(1, 1, 1, 1)
	end
end

local function _stopCurCo( self )
	if self.m_curCo then
		coroutine.stop(self.m_curCo)
	end
	self.m_curCo = nil
end

local _doRequestUrl = nil
_doRequestUrl = function ( self, url)
	_stopCurCo(self)
	if self.m_tryTimes >= kMaxTry then return end

	local co = coroutine.start(function() 
		local www = WWW(url);
		coroutine.wwwTimeOut(www, kTimeOut)
		if www.isDone then
			if www.error == nil then
				_onInitTexture(self, url, www.texture)
			else
				self.m_tryTimes = self.m_tryTimes + 1
				_doRequestUrl(self, url)
			end
		else
			self.m_tryTimes = self.m_tryTimes + 1
			_doRequestUrl(self, url)
		end
		self.m_curCo = nil
	end)
	self.m_curCo = co
end

function url_image_view:set_url( url )
	self.m_url = url
	self.m_tryTimes = 0
	self.m_rawImage.color = UnityEngine.Color(1, 1, 1, 0)
	_doRequestUrl(self, url)
end

function url_image_view:on_uninit()
	_stopCurCo(self)
end

return url_image_view