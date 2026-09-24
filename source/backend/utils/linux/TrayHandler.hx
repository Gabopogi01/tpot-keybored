package backend.utils.linux;

#if linux
@:headerCode('
extern "C" {
    void init_tray_icon(const char* icon_path_or_name);
    void update_gtk_events();
}
')
#end

class TrayHandler {
    public static function init():Void {
        #if linux
        untyped __cpp__("init_tray_icon({0})", "application-default");
        #end
    }

    public static function update():Void {
        #if linux
        untyped __cpp__("update_gtk_events()");
        #end
    }
}