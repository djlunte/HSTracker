class AppDelegate
  include CDQ

  Log = Motion::Log

  def applicationDidFinishLaunching(notification)
    # init logs
    Log.level = :debug

    Log.addLogger DDTTYLogger.sharedInstance

    return true if RUBYMOTION_ENV == 'test'

    file_logger                                        = DDFileLogger.new
    file_logger.rollingFrequency                       = 60 * 60 * 12
    file_logger.logFileManager.maximumNumberOfLogFiles = 7
    Log.addLogger file_logger

    cdq.setup

    show_splash_screen

    # load cards into database if needed
    DatabaseGenerator.init_database(@splash) do
      @splash.window.orderOut(self)
      @splash = nil

      NSApp.mainMenu = MainMenu.new.menu

      @player = PlayerTracker.new
      @player.showWindow(self)
      @player.window.orderFrontRegardless

      @opponent = OpponentTracker.new
      @opponent.showWindow(self)
      @opponent.window.orderFrontRegardless

      Game.instance.player_tracker   = @player
      Game.instance.opponent_tracker = @opponent

      Hearthstone.instance.on(:app_running) do |is_running|
        Log.info "Hearthstone is running? #{is_running}"
      end

      Hearthstone.instance.on(:app_activated) do |is_active|
        Log.info "Hearthstone is active? #{is_active}"
        if is_active
          @player.set_level NSScreenSaverWindowLevel
          @opponent.set_level NSScreenSaverWindowLevel
        else
          @player.set_level NSNormalWindowLevel
          @opponent.set_level NSNormalWindowLevel
        end
      end

      NSNotificationCenter.defaultCenter.observe 'deck_change' do |_|
        reload_deck_menu
      end

      if Hearthstone.instance.is_hearthstone_running?
        Hearthstone.instance.start
      end

      VersionChecker.check

      NSNotificationCenter.defaultCenter.observe 'AppleLanguages_changed' do |_|
        response = NSAlert.alert('Language change'._,
                                 :buttons     => ['OK'._, 'Cancel'._],
                                 :informative => 'You must restart HSTracker for the language change to take effect'._)
        if response == NSAlertFirstButtonReturn
          @app_will_restart = true

          NSApplication.sharedApplication.terminate(nil)
          exit(0)
        end
      end

      NSNotificationCenter.defaultCenter.observe 'open_deck_manager' do |notif|
        open_deck_manager notif.userInfo
      end

      if ImageCache.need_download?
        ask_download_images(nil)
      end
    end
  end

  def show_splash_screen
    @splash = LoadingScreen.new
    @splash.showWindow(nil)
  end

  # preferences
  def preferences
    @preferences ||= begin
      MASPreferencesWindowController.alloc.initWithViewControllers(
          [
              GeneralPreferences.new,
              InterfacePreferences.new,
              ColorPreferences.new
          ],
          title: 'Preferences'._)
    end
  end

  def openPreferences(_)
    preferences.showWindow(nil)
  end

  # deck manager
  def deck_manager
    @deck_manager ||= begin
      manager                 = DeckManager.new
      manager.window.delegate = self
      manager
    end
  end

  def open_deck_manager(data)
    # change windows level
    @player.set_level NSNormalWindowLevel
    @opponent.set_level NSNormalWindowLevel

    if data.is_a? Hash
      deck_manager.import(data)
    end

    deck_manager.showWindow(nil)
    deck_manager.player_view = @player

    close_window_menu true
  end

  # nswindowdelegate
  def windowShouldClose(_)
    deck_manager.check_is_saved_on_close
  end

  def windowWillClose(_)
    # change windows level back
    if Hearthstone.instance.is_active?
      @player.set_level NSScreenSaverWindowLevel
      @opponent.set_level NSScreenSaverWindowLevel
    end

    close_window_menu false
    @deck_manager = nil
  end

  # lock / unlock windows
  def lock_windows(menu_item)
    Configuration.windows_locked ? menu_item.title = 'Lock Windows'._ : menu_item.title = 'Unlock Windows'._

    Configuration.windows_locked = !Configuration.windows_locked
  end

  # open a deck
  def open_deck(menu_item)
    deck = Deck.by_name(menu_item.title)
    @player.show_deck(deck.playable_cards, deck.name)
  end

  # reset the trackers
  def reset(_)
    @player.game_start
    @opponent.game_start
    Hearthstone.instance.reset
  end

  def reload_deck_menu
    deck_menu = NSApp.mainMenu.itemWithTitle 'Decks'._
    deck_menu.submenu.removeAllItems

    item = NSMenuItem.alloc.initWithTitle('Deck Manager'._, action: 'open_deck_manager:', keyEquivalent: 'm')
    deck_menu.submenu.addItem item
    item = NSMenuItem.alloc.initWithTitle('Reset'._, action: 'reset:', keyEquivalent: 'r')
    deck_menu.submenu.addItem item
    deck_menu.submenu.addItem NSMenuItem.separatorItem

    Deck.all.sort_by(:name, :case_insensitive => true).each do |deck|
      item = NSMenuItem.alloc.initWithTitle(deck.name, action: 'open_deck:', keyEquivalent: '')
      deck_menu.submenu.addItem item
    end
  end

  def close_window_menu(enabled)
    window_menu          = NSApp.mainMenu.itemWithTitle 'Window'._
    close_window         = window_menu.submenu.itemWithTitle 'Close'._
    close_window.enabled = enabled
  end

  def performClose(_)
    if deck_manager
      deck_manager.window.performClose nil
    end
  end

  # restart HSTracker
  def applicationWillTerminate(_)
    if @app_will_restart
      app_path = NSBundle.mainBundle.bundlePath
      task     = NSTask.new
      task.setLaunchPath '/usr/bin/open'
      task.setArguments [app_path]
      task.launch
    end
  end

  def applicationShouldTerminate(_)
    response = NSTerminateNow

    if deck_manager
      can_close = deck_manager.check_is_saved_on_close
      unless can_close
        response = NSTerminateCancel
      end
    end

    response
  end

  def debug(_)
    @debugger ||= Debugger.new
    @debugger.showWindow(nil)
  end

  def ask_download_images(_)
    current_locale = Configuration.hearthstone_locale

    popup = NSPopUpButton.new
    popup.frame = [[0, 0], [299, 24]]

    GeneralPreferencesLayout::KHearthstoneLocales.each do |hs_locale, osx_locale|
      locale  = NSLocale.alloc.initWithLocaleIdentifier osx_locale
      display = locale.displayNameForKey(NSLocaleIdentifier, value: osx_locale)

      item = NSMenuItem.alloc.initWithTitle(display, action: nil, keyEquivalent: '')
      popup.menu.addItem item

      if current_locale == hs_locale
        popup.selectItem item
      end
    end

    if current_locale.nil?
      popup.selectItemAtIndex -1
    end

    rep = NSAlert.alert('Images'._,
                        :buttons     => ['OK'._],
                        :informative => 'Cards images are not found. Please confirm the Hearthstone language then click OK to download them.'._,
                        :view        => popup)
    if rep
      choosen = popup.selectedItem.title

      GeneralPreferencesLayout::KHearthstoneLocales.each do |hs_locale, osx_locale|
        locale  = NSLocale.alloc.initWithLocaleIdentifier osx_locale
        display = locale.displayNameForKey(NSLocaleIdentifier, value: osx_locale)

        if choosen == display
          Configuration.hearthstone_locale = hs_locale
        end
      end

      download_images
    end
  end

  def download_images
    @downloader = Downloader.new
    @downloader.showWindow(nil)
    @downloader.download do
      NSUserDefaults.standardUserDefaults.setObject(ImageCache::IMAGES_VERSION, forKey: 'image_version')

      @downloader.close
      @downloader = nil
    end
  end
end
