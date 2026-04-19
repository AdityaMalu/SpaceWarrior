require 'spec.helper'

describe('modules.audio', function()
    local audio
    local created

    before_each(function()
        created = {}

        _G.love = _G.love or {}
        _G.love.audio = {
            newSource = function(path, sourceType)
                local source = {
                    path = path,
                    sourceType = sourceType,
                    volume = 1,
                    looping = false,
                    playCount = 0,
                    stopCount = 0,
                }

                function source:setVolume(value)
                    self.volume = value
                end

                function source:getVolume()
                    return self.volume
                end

                function source:setLooping(value)
                    self.looping = value
                end

                function source:play()
                    self.playCount = self.playCount + 1
                end

                function source:stop()
                    self.stopCount = self.stopCount + 1
                end

                table.insert(created, source)
                return source
            end,
        }

        _G.AUDIO_VOLUMES = { master = 0.8, music = 0.5, sfx = 0.25 }
        package.loaded['modules.audio'] = nil
        audio = require 'modules.audio'
    end)

    it('applies master and bus volume to new sources', function()
        local music = audio.newSource('song.ogg', 'static', 'music')
        music:setVolume(0.5)
        assert.is_true(math.abs(audio.sources[1].source.volume - 0.2) < 1e-6)
    end)

    it('updates only the targeted bus when setBus is used', function()
        local music = audio.newSource('song.ogg', 'static', 'music')
        local sfx = audio.newSource('shoot.wav', 'static', 'sfx')

        music:setVolume(0.5)
        sfx:setVolume(1.0)
        audio.setBus('music', 0.3)

        assert.is_true(math.abs(audio.sources[1].source.volume - 0.12) < 1e-6)
        assert.is_true(math.abs(audio.sources[2].source.volume - 0.2) < 1e-6)
    end)

    it('recomputes registered source volumes from AUDIO_VOLUMES on apply', function()
        local sfx = audio.newSource('shoot.wav', 'static', 'sfx')

        sfx:setVolume(0.4)
        _G.AUDIO_VOLUMES.master = 0.5
        _G.AUDIO_VOLUMES.sfx = 0.1
        audio.apply()

        assert.is_true(math.abs(audio.sources[1].source.volume - 0.02) < 1e-6)
    end)
end)