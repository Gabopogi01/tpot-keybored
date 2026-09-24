package backend.utils;

#if windows
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

#if linux
@:headerCode('
#include <X11/Xlib.h>
#include <X11/keysym.h>

#pragma push_macro("Status")
#pragma push_macro("KeyCode")
#undef Status
#undef KeyCode
')

@:buildXml('
<target id="haxe">
  <cflag value="`pkg-config --cflags gtk+-3.0 ayatana-appindicator3-0.1`"/>
  <linkerflag value="`pkg-config --libs gtk+-3.0 ayatana-appindicator3-0.1`"/>
  <linkerflag value="-lX11"/>
</target>
')

@:cppFileCode('
#include <gtk/gtk.h>
#include <libayatana-appindicator/app-indicator.h>

#undef TRUE
#undef FALSE
#undef Status
#undef KeyCode

#define ID_BUTTON_A  1004  
#define ID_BUTTON_B  1005  
#define ID_TRAY_EXIT 1006  

static AppIndicator *indicator = NULL;
void (*onMenuClickedInHaxe)(int itemID) = NULL;

static void on_menu_item_clicked(GtkWidget *widget, gpointer data) {
    int id = GPOINTER_TO_INT(data);

    if (onMenuClickedInHaxe != NULL) {
        onMenuClickedInHaxe(id);
    }

    switch (id) {
        case ID_BUTTON_A:
            break;
        case ID_BUTTON_B:
            break;
        case ID_TRAY_EXIT:
            gtk_main_quit();
            break;
    }
}

extern "C" {

    void init_tray_icon(const char* icon_path_or_name) {
        gtk_init_check(NULL, NULL);

        indicator = app_indicator_new(
            "my-app-indicator",
            icon_path_or_name, 
            APP_INDICATOR_CATEGORY_APPLICATION_STATUS
        );
        app_indicator_set_status(indicator, APP_INDICATOR_STATUS_ACTIVE);

        GtkWidget *menu = gtk_menu_new();

        GtkWidget *item_a = gtk_menu_item_new_with_label("Show Window");
        g_signal_connect(item_a, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_BUTTON_A));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_a);

        GtkWidget *item_b = gtk_menu_item_new_with_label("Hide Window");
        g_signal_connect(item_b, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_BUTTON_B));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_b);

        GtkWidget *sep = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), sep);

        GtkWidget *item_exit = gtk_menu_item_new_with_label("Exit App");
        g_signal_connect(item_exit, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_TRAY_EXIT));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_exit);

        gtk_widget_show_all(menu);
        app_indicator_set_menu(indicator, GTK_MENU(menu));
    }

   void init_tray_icon_with_pixels(const unsigned char* pixels, int width, int height) {
        gtk_init_check(NULL, NULL);

        // Swapped uppercase TRUE to lowercase true
        GdkPixbuf *pixbuf = gdk_pixbuf_new_from_data(
            pixels,
            GDK_COLORSPACE_RGB,
            true, 
            8,    
            width,
            height,
            width * 4, 
            NULL, NULL
        );

        indicator = app_indicator_new(
            "my-app-indicator",
            "applications-other", 
            APP_INDICATOR_CATEGORY_APPLICATION_STATUS
        );
        app_indicator_set_status(indicator, APP_INDICATOR_STATUS_ACTIVE);

        if (pixbuf != NULL) {
            const char* temp_path = "/tmp/tpot_keybored_tray_icon.png";
            gdk_pixbuf_save(pixbuf, temp_path, "png", NULL, NULL);
            g_object_unref(pixbuf);
            app_indicator_set_icon_full(indicator, temp_path, "App Icon");
        }

        GtkWidget *menu = gtk_menu_new();

        GtkWidget *item_a = gtk_menu_item_new_with_label("Show Window");
        g_signal_connect(item_a, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_BUTTON_A));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_a);

        GtkWidget *item_b = gtk_menu_item_new_with_label("Hide Window");
        g_signal_connect(item_b, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_BUTTON_B));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_b);

        GtkWidget *sep = gtk_separator_menu_item_new();
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), sep);

        GtkWidget *item_exit = gtk_menu_item_new_with_label("Exit App");
        g_signal_connect(item_exit, "activate", G_CALLBACK(on_menu_item_clicked), GINT_TO_POINTER(ID_TRAY_EXIT));
        gtk_menu_shell_append(GTK_MENU_SHELL(menu), item_exit);

        gtk_widget_show_all(menu);
        app_indicator_set_menu(indicator, GTK_MENU(menu));
    }

    void update_gtk_events() {
        while (gtk_events_pending()) {
            gtk_main_iteration_do(false);
        }
    }
}
')
#end

class SomeUtils {
    private static var keyStates:Array<Bool> = [];

    public static function centerWindow(){
        #if desktop
        var window = openfl.Lib.application.window;
        var display = lime.system.System.getDisplay(0); 
        if (display != null) {
            var screenBounds = display.bounds;
            var centerX = Std.int((screenBounds.width - window.width) / 2);
            var centerY = Std.int((screenBounds.height - window.height) / 2);
            window.move(centerX, centerY);
        }
        #end
    }

    public static function init(){
        for (i in 0...512) { keyStates.push(false); }
    }

    public static function checkAndPlayKey(vk:Int, sound:String, ?vol:Float):Void {
        if (vol == null) vol = 1.0;

        var isDownNow:Bool = false;

        #if windows
        var state:Int = untyped __cpp__("GetAsyncKeyState({0})", vk);
        isDownNow = (state & 0x8000) != 0;
        #elseif linux
        untyped __cpp__('
            ::Display* dpy = ::XOpenDisplay(NULL);
            if (dpy) {
                char keys[32];
                ::XQueryKeymap(dpy, keys);
                
                ::KeyCode kc = ::XKeysymToKeycode(dpy, (::KeySym){0}); 
                
                if (kc != 0) {
                    isDownNow = (keys[kc / 8] & (1 << (kc % 8))) != 0;
                }
                
                ::XCloseDisplay(dpy);
            }
        ', vk);
        #end

        var wasDownBefore:Bool = keyStates[vk];
        if (isDownNow && !wasDownBefore) { 
            var keysSound = flixel.FlxG.sound.play(Paths.sound(sound)); 
            if (keysSound != null) {
                keysSound.volume = vol;
            }
        }
        keyStates[vk] = isDownNow;
    }
}
