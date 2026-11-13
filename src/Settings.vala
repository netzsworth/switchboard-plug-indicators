using Json;

public class Indicators.SettingUtils {
    private string settings_dir = GLib.Environment.get_user_config_dir () + "/indicators/";
    private const string SETTINGS_FILE = "indicators.json";
    private const string SETTINGS_INDICATORS_FILE = "indicatorNames.json";
    private GLib.File settings_file;
    private GLib.File settings_indicator_names_file;
    private GLib.FileMonitor? monitor;

    private Gee.HashSet<string> namarupa_indicators;
    private Gee.HashSet<string> all_indicator_names;
    private bool show_empty_namarupa_indicator;
    public bool is_installed { get; private set; default = true; }

    public SettingUtils () {
        namarupa_indicators = new Gee.HashSet<string> ();
        all_indicator_names = new Gee.HashSet<string> ();
        settings_file = File.new_for_path (settings_dir + SETTINGS_FILE);
        settings_indicator_names_file = File.new_for_path (settings_dir + SETTINGS_INDICATORS_FILE);

        if (!settings_file.query_exists () || !settings_indicator_names_file.query_exists ()) {
            warning ("Settings files in %s do not exist. Install community indicators first.", settings_dir);
            is_installed = false;
            return;
        }

        get_settings_from_json_string (read_file (settings_file));
        all_indicator_names = get_indicator_names_from_file (settings_indicator_names_file);

        try {
            monitor = settings_indicator_names_file.monitor (GLib.FileMonitorFlags.NONE);
            monitor.changed.connect (all_indicators_file_changed);
        } catch (Error e) {
            warning ("Unable to monitor %s: %s", settings_indicator_names_file.get_path (), e.message);
        }
    }

    private void all_indicators_file_changed (GLib.File file, GLib.File? other_file, GLib.FileMonitorEvent event) {
        if (event == GLib.FileMonitorEvent.CHANGED || event == GLib.FileMonitorEvent.CREATED) {
            all_indicator_names = get_indicator_names_from_file (settings_indicator_names_file);
            settings_updated ();
        }
    }

    private string read_file (File file) {
        string output = "";
        try {
            GLib.FileUtils.get_contents (file.get_path (), out output);
        } catch (Error e) {
            warning ("Unable to read %s: %s", file.get_path (), e.message);
        }
        return output;
    }

    private void write_file (File file, string content) {
        try {
            GLib.FileUtils.set_contents (file.get_path (), content);
        } catch (Error e) {
            warning ("Unable to write %s: %s", file.get_path (), e.message);
        }
    }

    private string generate_json_string () {
        var builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name ("namarupaIndicators");
        builder.begin_array ();
        foreach (string name in namarupa_indicators) {
            builder.add_string_value (name);
        }
        builder.end_array ();
        builder.set_member_name ("showEmptyNamarupaIndicator");
        builder.add_boolean_value (show_empty_namarupa_indicator);
        builder.end_object ();

        var generator = new Json.Generator ();
        generator.set_root (builder.get_root ());
        return generator.to_data (null);
    }

    private void get_settings_from_json_string (string json_string) {
        var parser = new Json.Parser ();
        try {
            parser.load_from_data (json_string, -1);
            var object = parser.get_root ().get_object ();
            var indicator_list = object.get_array_member ("namarupaIndicators");
            foreach (var node in indicator_list.get_elements ()) {
                namarupa_indicators.add (node.get_string ());
            }
            show_empty_namarupa_indicator = object.get_boolean_member ("showEmptyNamarupaIndicator");
        } catch (Error e) {
            warning ("Unable to parse indicator settings: %s", e.message);
        }
    }

    private Gee.HashSet<string> get_indicator_names_from_file (File file) {
        var names = new Gee.HashSet<string> ();
        var parser = new Json.Parser ();
        try {
            parser.load_from_data (read_file (file), -1);
            var indicator_list = parser.get_root ().get_object ().get_array_member ("allIndicators");
            foreach (var node in indicator_list.get_elements ()) {
                names.add (node.get_string ());
            }
        } catch (Error e) {
            warning ("Unable to parse indicator names: %s", e.message);
        }
        return names;
    }

    public Gee.HashSet<string> get_non_namarupa_indicator_names () {
        var names = new Gee.HashSet<string> ();
        foreach (string name in all_indicator_names) {
            if (!namarupa_indicators.contains (name)) {
                names.add (name);
            }
        }
        return names;
    }

    public Gee.HashSet<string> get_namarupa_indicator_names () {
        return namarupa_indicators;
    }

    public void toggle_namarupa_for_indicator (string name) {
        if (namarupa_indicators.contains (name)) {
            namarupa_indicators.remove (name);
        } else {
            namarupa_indicators.add (name);
        }
        write_file (settings_file, generate_json_string ());
        settings_updated ();
    }

    public string get_indicator_path () {
        return settings_dir + "icons/";
    }

    public bool get_show_empty_namarupa () {
        return show_empty_namarupa_indicator;
    }

    public signal void settings_updated ();
}
