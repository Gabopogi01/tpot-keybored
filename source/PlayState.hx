package;

import flixel.FlxState;
import flixel.FlxG;
import backend.Paths;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import haxe.ui.Toolkit;
import haxe.ui.ComponentBuilder;
import flixel.system.FlxAssets;
import flixel.FlxSprite;
import haxe.ui.components.Label;
import haxe.ui.components.Slider;
import backend.utils.SomeUtils;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import flixel.util.FlxTimer;
import haxe.ui.containers.windows.Window;
import sys.FileSystem;
import hxwindowmode.WindowColorMode;
import haxe.ui.containers.windows.WindowManager;
import haxe.ui.events.MouseEvent;
import haxe.ui.components.CheckBox;
import haxe.ui.events.UIEvent;
import haxe.ui.containers.menus.MenuItem;
import backend.special.PreviewMode;

#if cpp
@:cppFileCode('
#include <windows.h>
#include <shellapi.h>

#pragma comment(lib, "shell32.lib")
#pragma comment(lib, "user32.lib")

#define WM_TRAYICON (WM_USER + 1)
#define ID_BUTTON_A  1004  
#define ID_BUTTON_B  1005  
#define ID_TRAY_EXIT 1006  

NOTIFYICONDATAW nid = { 0 };
WNDPROC oldWndProc = NULL;
void (*onMenuClickedInHaxe)(int itemID) = NULL;

LRESULT CALLBACK TrayWndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp) {
    if (msg == WM_TRAYICON) {
        if (LOWORD(lp) == WM_RBUTTONUP) {
            HMENU hMenu = CreatePopupMenu();
            if (hMenu) {
                AppendMenuW(hMenu, MF_STRING, ID_BUTTON_A, L"Show Window");
                AppendMenuW(hMenu, MF_STRING, ID_BUTTON_B, L"Hide Window");
                
                AppendMenuW(hMenu, MF_SEPARATOR, 0, NULL);
                AppendMenuW(hMenu, MF_STRING, ID_TRAY_EXIT, L"Exit App");

                POINT pt;
                GetCursorPos(&pt);
                SetForegroundWindow(hwnd); 
                TrackPopupMenu(hMenu, TPM_BOTTOMALIGN | TPM_LEFTALIGN, pt.x, pt.y, 0, hwnd, NULL);
                DestroyMenu(hMenu);
            }
        }
    }
    else if (msg == WM_COMMAND) {
        int id = LOWORD(wp);
        
        if (onMenuClickedInHaxe != NULL) {
            onMenuClickedInHaxe(id);
        }

        switch (id) {
            case ID_BUTTON_A: ShowWindow(hwnd, SW_SHOW); break;
            case ID_BUTTON_B: ShowWindow(hwnd, SW_HIDE); break;
            case ID_TRAY_EXIT: Shell_NotifyIconW(NIM_DELETE, &nid); ExitProcess(0); break;
        }
    }
    return CallWindowProc(oldWndProc, hwnd, msg, wp, lp);
}
')
#end
// @:nullSafety
class PlayState extends FlxState
{
    private static var lastClickedMenuID:Int = -1;
    private var myUi:Dynamic;
    private var bg:FlxSprite;
    private var fg:FlxSprite;
    private var bg_d:FlxSprite;
    private var fg_d:FlxSprite;
    private var soundMusc:FlxSound;
    public var mainVol:Float = 1;
    public var lastmainVol:Float = 1;
    private var myWindow:Window;
    private var titleSong:String;
    public var useAginsounds = false;

    override public function create()
    {
        FlxAssets.FONT_DEFAULT = Paths.font("SEGUISB");
		Toolkit.init();
        PreviewMode.init();

        Toolkit.styleSheet.parse('* { 
            font-name: "' + FlxAssets.FONT_DEFAULT  + '";
            font-size: 14px; 
            cursor: default;
        }', "user");

        WindowColorMode.setWindowBorderColor([246,246,246]);

        @:privateAccess {
            if (haxe.ui.Toolkit._initialized) {
				FlxG.signals.postGameStart.add(haxe.ui.core.Screen.instance.onPostGameStart);
				FlxG.signals.postStateSwitch.add(haxe.ui.core.Screen.instance.onPostStateSwitch);
				FlxG.signals.preStateCreate.add(haxe.ui.core.Screen.instance.onPreStateCreate);
                
                haxe.ui.core.Screen.instance.onPreStateCreate(this);
            }
        }
        FlxG.camera.antialiasing = true;

        fg = new FlxSprite().loadGraphic(Paths.image("frontground"));

        bg = new FlxSprite().loadGraphic(Paths.image("background"));
        add(bg);
        add(fg);

        bg.scale.set(0.6, 0.6);
        fg.scale.set(0.6, 0.6);
        bg.updateHitbox();
        fg.updateHitbox();
        bg.screenCenter();
        fg.screenCenter();

        bg.scrollFactor.set(0.5, 0.5); 
        fg.scrollFactor.set(0.3, 0.3); 

        fg_d = new FlxSprite().loadGraphic(Paths.image("darl/frontground"));

        bg_d = new FlxSprite().loadGraphic(Paths.image("darl/background"));
        add(bg_d);
        add(fg_d);

        bg_d.scale.set(0.4, 0.4);
        fg_d.scale.set(0.4, 0.4);
        bg_d.updateHitbox();
        fg_d.updateHitbox();
        bg_d.screenCenter();
        fg_d.screenCenter();

        bg_d.scrollFactor.set(0.5, 0.5); 
        fg_d.scrollFactor.set(0.3, 0.3); 

        super.create();

		myUi = ComponentBuilder.fromFile("assets/data/layouts/settings.xml");
        myUi.scrollFactor.set(0, 0); 
		add(myUi);
		createTrayIcon();
        musicbutsound();

        bg_d.visible = fg_d.visible = false;

        for (i in FileSystem.readDirectory("assets/sounds/music/light")){
            trace('cached $i' );
            FlxG.sound.cache("assets/sounds/music/light/light" + i.length);
        }

        for (i in FileSystem.readDirectory("assets/sounds/music/the dark")){
            trace('cached $i' );
            FlxG.sound.cache("assets/sounds/music/the dark/dark" + i.length);
        }

        var openBtn = cast(myUi.findComponent("openwinHAUISHDIUASHD"), MenuItem);
        if (openBtn != null) {
            openBtn.onClick = function(e:MouseEvent) {
                myWindow = ComponentBuilder.fromFile("assets/data/layouts/muscInfo.xml");
                cast(myWindow, Window).title = "Music info and Settings";
                var infoLabel = cast(myWindow.findComponent('infoo'), Label);
                if (infoLabel != null) {
                    infoLabel.text = " Now Playing: " + titleSong;
                }
                var volSlider = cast(myWindow.findComponent("volb"), Slider);
                volSlider.pos = mainVol * 100;
                var check = cast(myWindow.findComponent("mure"), CheckBox);
                volSlider.disabled = check.selected;

                WindowManager.instance.addWindow(myWindow);
            }
        }
        PreviewMode.prev();
    }

    @:keep
    public static function haxeMenuCallback(itemID:Int):Void
    {
        lastClickedMenuID = itemID;
    }

    private var timer:FlxTimer;
    var infoLabel:Label;

    private function musicbutsound():Void {
        if (timer != null) timer.cancel();
        if (soundMusc != null) soundMusc.stop(); 
        #if debug
        trace("music");
        #end
        timer = new FlxTimer().start(FlxG.random.float(3, 5), (tmr:FlxTimer) -> { 
            var rand:Int = 0;
            var soundPath:String = "";

            if (Toolkit.theme == "dark") {
                rand = FlxG.random.int(1, 5);
                soundPath = "music/the dark/dark" + rand;
            } else {
                rand = FlxG.random.int(1, 4);
                soundPath = "music/light/light" + rand;
            }

            soundMusc = FlxG.sound.create(Paths.sound(soundPath, "ogg")).setup().play();
            titleSong = soundPath;
            if (myWindow != null){
                infoLabel = cast(myWindow.findComponent('infoo'), Label);
                if (infoLabel != null) infoLabel.text = " Now Playing: " + titleSong;
            }

            soundMusc.volume = 0;
            if (soundMusc != null) soundMusc.onComplete = ()->{musicbutsound();};
            #if debug
            trace(soundMusc);
            #end
        });
    }

    // @bind()

    var lastTheme = Toolkit.theme;
    var check:CheckBox;
    var oldSel = false;
    var dontSlide = false;
    var volSlider:Slider;
    var lastThemea = true;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

        FlxG.mouse.useSystemCursor = true;

        if (soundMusc != null){
            FlxTween.cancelTweensOf(soundMusc);
            FlxTween.tween(soundMusc, {volume: mainVol}, 0.5);
        }

        if (Toolkit.theme != lastTheme) {
            if (Toolkit.theme == "dark") {
                bg_d.visible = fg_d.visible = true;
                WindowColorMode.setWindowBorderColor([61,63,65]);
                WindowColorMode.setDarkMode();
            } else {
                bg_d.visible = fg_d.visible = false;
                WindowColorMode.setWindowBorderColor([246,246,246]);
                WindowColorMode.setLightMode();
            }
            soundMusc.stop();
            lastTheme = Toolkit.theme;
            musicbutsound();
        }

        if (myWindow != null) {
            check = cast(myWindow.findComponent("mure"), CheckBox);
            volSlider = cast(myWindow.findComponent("volb"), Slider);
        }

        #if preview
            if (FlxG.keys.pressed.ENTER){
                if (lastThemea){
                    Toolkit.theme = "dark";
                    lastThemea = false;
                } else {
                    Toolkit.theme = "default";
                    lastThemea = true;
                }
            }
        #end

        if (check != null && oldSel != check.selected){
            // trace("a");
            if (check.selected){
                lastmainVol = mainVol;
                mainVol = 0;
                // trace("off");
                dontSlide = true;
            } else {
                mainVol = lastmainVol;
                // trace("on");
                dontSlide = false;
            }
            volSlider.disabled = check.selected;
            oldSel = check.selected;
        }

        if (lastClickedMenuID != -1)
        {
            var idToProcess:Int = lastClickedMenuID;
            lastClickedMenuID = -1;

            switch (idToProcess) 
            {
                case 1004:
					FlxTween.cancelTweensOf(lime.app.Application.current.window);
					lime.app.Application.current.window.width = 0;
					lime.app.Application.current.window.height = 0;
					lime.app.Application.current.window.visible = true;
					
					FlxTween.tween(lime.app.Application.current.window, {width: 1280, height: 720}, 1, {
                        ease: FlxEase.expoOut,
                        onUpdate: function(twn:FlxTween) {
                            backend.utils.SomeUtils.centerWindow();
                        }
                    });

                case 1005:
					lime.app.Application.current.window.visible = false;
            }
        }
        var volSlidera = cast(myUi.findComponent("volSound"), Slider);

		for (vk in 0...13) { SomeUtils.checkAndPlayKey(vk, FlxG.random.bool(50) ? "ButtonPress" : "ButtonPressALT", volSlidera.pos / 100); }
		for (vk in 14...64) { SomeUtils.checkAndPlayKey(vk, FlxG.random.bool(50) ? "ButtonPress" : "ButtonPressALT", volSlidera.pos / 100); }
		for (vk in 92...300) { SomeUtils.checkAndPlayKey(vk, FlxG.random.bool(50) ? "ButtonPress" : "ButtonPressALT", volSlidera.pos / 100); }
		for (vk in 65...91) { 
            if (!useAginsounds){
                SomeUtils.checkAndPlayKey(vk, "press/Press" + String.fromCharCode(vk).toUpperCase(), volSlidera.pos / 100);
            } else {
                SomeUtils.checkAndPlayKey(vk, "again/Retry" + String.fromCharCode(vk).toUpperCase(), volSlidera.pos / 100);
            }
        }
		SomeUtils.checkAndPlayKey(13, "Success");

        // var voxComponent = myUi.findComponent("kenneythemevox");
        //cast(voxComponent, OptionBox).disabled = true;

        if (myWindow != null && !dontSlide) {
            var volSlider = cast(myWindow.findComponent("volb"), Slider);
            if (volSlider != null) {
                mainVol = volSlider.pos / 100;
            }
        }

        // if (haxe.ui.themes.ThemeManager.instance.getTheme("kenneay") == null) cast(voxComponent, OptionBox).disabled = true;

        var mouseX = (FlxG.mouse.viewX - (FlxG.width/2)) / 30;
        var mouseY = (FlxG.mouse.viewY - (FlxG.height/2)) / 30;

        FlxG.camera.scroll.x = FlxMath.lerp(FlxG.camera.scroll.x, mouseX,1-Math.exp(-elapsed * 5));
        FlxG.camera.scroll.y = FlxMath.lerp(FlxG.camera.scroll.y, mouseY,1-Math.exp(-elapsed * 5));
	}

    public function createTrayIcon():Void
    {
        #if windows
        var nativeCallable = cpp.Function.fromStaticFunction(haxeMenuCallback);
        untyped __cpp__("
            HWND hwnd = GetActiveWindow();
            if (hwnd == NULL) { hwnd = GetForegroundWindow(); }
            
            if (hwnd != NULL) {
                onMenuClickedInHaxe = {0}; 
                nid.cbSize = sizeof(NOTIFYICONDATAW);
                nid.hWnd = hwnd;
                nid.uID = 1;
                nid.uFlags = NIF_ICON | NIF_TIP | NIF_MESSAGE; 
                nid.uCallbackMessage = WM_TRAYICON;
                nid.hIcon = LoadIcon(GetModuleHandle(NULL), MAKEINTRESOURCE(1)); 
                lstrcpyW(nid.szTip, L\"Keypress Audio Engine\"); 
                Shell_NotifyIconW(NIM_ADD, &nid);
                if (oldWndProc == NULL) { oldWndProc = (WNDPROC)SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)TrayWndProc); }
                
                ShowWindow(hwnd, SW_HIDE);
            }
        ", nativeCallable);
        #end
    }

    public function removeTrayIcon():Void
    {
        #if windows
        untyped __cpp__("
            Shell_NotifyIconW(NIM_DELETE, &nid);
            if (oldWndProc != NULL) {
                HWND hwnd = GetActiveWindow();
                if (hwnd != NULL) { SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)oldWndProc); oldWndProc = NULL; }
            }
        ");
        #end
    }

	override public function destroy() { 
		removeTrayIcon();
		
		super.destroy(); 
	}
}
