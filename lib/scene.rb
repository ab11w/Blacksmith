#~ module Chingu
	#~ class Viewport
		#~ def center_around(object)
			#~ self.x = object.x - $window.width / 2
			#~ self.y = object.y - $window.height / 2
		#~ end
	#~ end
#~ end

# ------------------------------------------------------
# Scenes
# What's happening in each blocks?
# ------------------------------------------------------
class Scene < GameState
	traits :viewport, :timer
	attr_reader :player, :terrain, :area, :backdrop, :hud

	def initialize
		super
		self.input = { :escape => :exit, :e => :edit, :r => :restart, :space => Pause }
		@backdrop = Parallax.new(:rotation_center => :top_left, :zorder => 10)
		@area = [0,0]
		#~ @file = File.join(ROOT, "levels/#{self.class.to_s.downcase}.yml")
		@file = File.join(ROOT, "#{self.class.to_s.downcase}.yml")
		@tiles = []
		@recorded_tilemap = nil
		$window.clear_cache
		player_start
		@hud = HUD.create(:player => @player) # if @hud == nil
		@player.sword = nil
		#~ $window.set_terrains
		game_objects.select { |game_object| !game_object.is_a? Player }.each { |game_object| game_object.destroy }
		load_game_objects(:file => @file) unless self.class.to_s == "Zero"
		#~ for i in 0...$game_tiles.size
			#~ @tiles = game_objects.grep($game_tiles[i])
		#~ end
		#~ p game_objects
		for i in 0...$window.terrains.size
			#~ j = game_objects.grep($game_terrains[i])
			@tiles += game_objects.grep($window.terrains[i])
		end
		#~ @tiles = game_objects.grep(Ground)
		#~ @tiles += game_objects.grep(GroundTiled)
		game_objects.subtract_with(@tiles)
		#~ p @tiles
		#~ p game_objects
		#~ between(200,400) {
		#~ @player.move_right
		#~ }.then { @player.stand_still; $window.stop_transferring }
		after(350) { $window.stop_transferring }
		#~ @song = Gosu::Song.new("media/bgm/silence-of-daylight.ogg")
		#~ @song.volume = 0.3
		#~ @song.play(true)
		#~ p "same" if $window.map.current_level == $window.level - 1
		#~ if ($window.map.current_level ==  $window.level - 1) && $window.map.current_block == 0
		#~ if $window.map.current_block == 0
			#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.map.current_level]}.ogg", :volume => 0.3)
			#~ $game_bgm.play(true)
		#~ end
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ p "#{Module_Game::BGM[$window.map.current_level]}.ogg"
		#~ p "#{Module_Game::BGM}"
		@hud.update
		#~ @tiles = @game_objects.grep(Ground)
	end
	
	def draw
		#~ @backdrop.draw
		@hud.draw unless @hud == nil
		# Draw the static tilemap all at once and ONLY once.
		@recorded_tilemap ||= $window.record 1, 1 do
			@tiles.each &:draw
		end
		@recorded_tilemap.draw 0, 0, 0

		super
	end
	
	def edit
		#~ push_game_state(GameStates::Edit.new(:grid => [8,8], :classes => [Zombie, GroundTiled, GroundLower, GroundLoop, GroundBack, BridgeGrayDeco, BridgeGrayDecoL, BridgeGrayDecoR, BridgeGrayDecoM, BridgeGraySmall, BridgeGrayLeftSmall, BridgeGrayRightSmall, BridgeGrayPoleSmall, BridgeGrayMidSmall, Zombie, Ball_Rang, Ball,Ground] ))
		push_game_state(GameStates::Edit.new(:grid => [8,8], :classes => [Zombie, Ball, Ball_Knife, Ball_Rang, Ball_Axe, Ground, GroundTiled, GroundLower, GroundLoop, GroundBack] ))
	end
	
	def clear_game_terrains
		@tiles.each {|me| me.destroy}
	end
	
	def restart
		#~ switch_game_state($window.map.first_block)
		#~ $window.block = 1
		#~ $window.setup_player
		$window.reset_stage
		clear_game_terrains
	end
	
	def player_start
		@player = Player.create()
		@player.reset_state
	end
	
	def to_next_block
		@player.status = :blink
		@player.sword.die if @player.sword != nil
		$window.transferring
		#~ $window.block += 1
		switch_game_state($window.map.next_block)
		$window.block += 1
		#~ after(100) { $window.stop_transferring }
	end
	
	def to_next_level
		@player.status = :blink
		@player.sword.die if @player.sword != nil
		$window.transferring
		#~ $window.block += 1
		switch_game_state($window.map.next_level)
		$window.level += 1
		$window.block  = 1
		#~ after(100) { $window.stop_transferring }
	end
	
	def update
		super
		@hud.update
		#~ update_trait
		self.viewport.center_around(@player)
		$window.enemies.each { |enemy| 
			if enemy.paused?
				after(500) {enemy.unpause!}
			end
		}
		Knife.destroy_if {|knife| 
			knife.x > self.viewport.x + $window.width + $window.width/8 or 
			knife.x < self.viewport.x - + $window.width/8 or 
			self.viewport.outside_game_area?(knife)
		}
		Axe.destroy_if {|axe| axe.y > self.viewport.y + $window.height or axe.x < self.viewport.x or axe.x > self.viewport.x + $window.width}
		Rang.destroy_if {|rang| self.viewport.outside_game_area?(rang) and rang.turn_back }
		if @player.y > self.viewport.y + $window.height/2 + @player.height/2
			@player.dead 
		end
		#~ $window.caption = "Scene0, FPS: #{$window.fps}, #{@player.x.to_i}:#{@player.y.to_i}[#{@player.velocity_y.to_i}-#{@player.y_flag}], #{$window.subweapon}, #{self.viewport.game_area}"
		$window.caption = "Scene0, FPS: #{$window.fps}, #{@player.status}, #{@player.action}, #{@player.y_flag}"
	end
end

class Level00 < Scene
	def initialize
		super
		#~ @area = [592,288]
		#~ @area = [592, 416]
		@area = [384, 288]
		#~ @area = [592, 288]
		@player.x = 64
		@player.y = 247
		#~ @player.y = 246
		#~ @player.y = 360
		@player.y_flag = @player.y
		self.viewport.game_area = [0,0,@area[0],@area[1]]
		@backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		@backdrop << {:image => "parallax/bg1-1.png", :damping => 5, :repeat_x => true, :repeat_y => false}
	
		#~ every(1){
			#~ @player.move_right
		#~ }
	
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
	end
	
	def draw
		@backdrop.draw
		super
	end
	 
	def update
		super
		#~ @player.move_right
		if @player.x >= @area[0]-(@player.bb.width) && (@player.y > 245 && @player.y < 248)
			to_next_block
		end
		@backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		@backdrop.update
	end
end

class Level01 < Scene
	def initialize
		super
		@area = [384,288]
		@player.x = self.viewport.x+(@player.bb.width/2)+16 # 32
		@player.y = 246
		@player.y_flag = @player.y
		self.viewport.game_area = [0,0,@area[0],@area[1]]
		@backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		@backdrop << {:image => "parallax/bg1-1.png", :damping => 1, :repeat_x => true, :repeat_y => false}
	
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
	end
	
	def draw
		@backdrop.draw
		super
	end
	 
	def update
		super
		#~ if @player.x >= @area[0]-(@player.bb.width) && (@player.y > 214 && @player.y < 216) # self.viewport.x+$window.width-(@player.bb.width/2)-1
			#~ to_next_block
		#~ end
		#~ @backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		@backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		@backdrop.update
	end
end

#~ class Level10 < Scene
	#~ def initialize
		#~ super
		#~ every(2000){@text = Text.create(:name => :woof, :text => "Woof!", :x=>@player.x, :y=>100, :size=>10, :zorder => 400)}
		#~ @area = [592,288]
		#~ @player.x = 32
		#~ @player.y = 246
		#~ @player.y_flag = @player.y
		#~ self.viewport.game_area = [0,0,@area[0],@area[1]]
		#~ @backdrop << {:image => "parallax/panorama1-1.png", :damping => 10, :repeat_x => true, :repeat_y => false}
		#~ @backdrop << {:image => "parallax/bg1-1.png", :damping => 1, :repeat_x => true, :repeat_y => false}
	
		#~ $game_bgm = Gosu::Song.new("media/bgm/#{Module_Game::BGM[$window.level-1]}.ogg", :volume => 0.3)
		#~ $game_bgm.play(true)
		#~ @song = Gosu::Song.new("media/bgm/silence-of-daylight.ogg")
		#~ @song.volume = 0.3
		#~ @song.play(true)
	#~ end
	
	#~ def draw
		#~ @backdrop.draw
		#~ fill_gradient(:from => Color.new(0xff444AFF), :to => Color.new(0xff444AFF), :zorder => -1)
		#~ super
	#~ end
	 
	#~ def update
		#~ super
		#~ if @player.x >= @area[0]-(@player.bb.width) && (@player.y > 214 && @player.y < 216) # self.viewport.x+$window.width-(@player.bb.width/2)-1
			#~ to_next_block
		#~ end
		#~ @backdrop.camera_x, @backdrop.camera_y = self.viewport.x.to_i, self.viewport.y.to_i
		#~ @backdrop.update
	#~ end
#~ end