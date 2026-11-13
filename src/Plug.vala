public class Indicators.Plug : Switchboard.Plug {
    private Gtk.Grid main_grid;
    private SettingUtils settings_util;
    private Gtk.Box non_namarupa_icons_box;
    private Gtk.Box namarupa_icons_box;

    public Plug () {
        var settings = new Gee.TreeMap<string, string?> (null, null);
        settings.set ("indicators", null);

        Object (
            category: Category.PERSONAL,
            code_name: "com.github.mvbonin.switchboard-plug-indicators",
            display_name: "Indicators",
            description: "Change community-indicators settings.",
            icon: "view-more-horizontal-symbolic",
            supported_settings: settings
        );

        settings_util = new SettingUtils ();
        settings_util.settings_updated.connect (update_hbox_widgets);
    }

    private Gtk.Box create_hbox (Gee.HashSet<string> names) {
        var hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
        hbox.set_homogeneous (true);

        foreach (var name in names) {
            var file = File.new_for_path (settings_util.get_indicator_path () + name.replace ("/", "..") + ".png");
            if (!file.query_exists ()) {
                continue;
            }

            var button = new Gtk.Button ();
            var image = new Gtk.Image.from_file (file.get_path ());
            image.set_pixel_size (16);
            button.set_child (image);
            button.clicked.connect (() => {
                settings_util.toggle_namarupa_for_indicator (name);
            });
            hbox.append (button);
        }

        return hbox;
    }

    private void replace_box_contents (Gtk.Box box, Gee.HashSet<string> names) {
        Gtk.Widget? child = box.get_first_child ();
        while (child != null) {
            var next = child.get_next_sibling ();
            box.remove (child);
            child = next;
        }

        var replacement = create_hbox (names);
        child = replacement.get_first_child ();
        while (child != null) {
            var next = child.get_next_sibling ();
            replacement.remove (child);
            box.append (child);
            child = next;
        }
    }

    private void update_hbox_widgets () {
        if (!settings_util.is_installed) {
            return;
        }

        if (non_namarupa_icons_box == null) {
            non_namarupa_icons_box = create_hbox (settings_util.get_non_namarupa_indicator_names ());
            main_grid.attach (non_namarupa_icons_box, 0, 1, 1, 1);
        } else {
            replace_box_contents (non_namarupa_icons_box, settings_util.get_non_namarupa_indicator_names ());
        }

        if (namarupa_icons_box == null) {
            namarupa_icons_box = create_hbox (settings_util.get_namarupa_indicator_names ());
            main_grid.attach (namarupa_icons_box, 0, 4, 1, 1);
        } else {
            replace_box_contents (namarupa_icons_box, settings_util.get_namarupa_indicator_names ());
        }
    }

    public override Gtk.Widget get_widget () {
        if (main_grid == null) {
            main_grid = new Gtk.Grid () {
                row_spacing = 12,
                halign = Gtk.Align.CENTER
            };
            main_grid.margin_start = 30;
            main_grid.margin_end = 30;
            main_grid.margin_top = 30;
            main_grid.margin_bottom = 30;

            if (!settings_util.is_installed) {
                main_grid.attach (
                    new Gtk.Label ("Please install community indicators first and restart Wingpanel or the machine."),
                    0, 0, 1, 1
                );
            } else {
                main_grid.attach (new Gtk.Label ("Indicators that appear directly on Wingpanel"), 0, 0, 1, 1);
                main_grid.attach (new Gtk.Separator (Gtk.Orientation.HORIZONTAL), 0, 2, 1, 1);
                main_grid.attach (new Gtk.Label ("Indicators that appear in the menu"), 0, 3, 1, 1);
                main_grid.attach (new Gtk.Label ("Click an indicator to change its placement."), 0, 5, 1, 1);
                update_hbox_widgets ();
            }
        }

        return main_grid;
    }

    public override void search_callback (string location) {
    }

    public override async Gee.TreeMap<string, string> search (string search) {
        return new Gee.TreeMap<string, string> (null, null);
    }

    public override void shown () {
    }

    public override void hidden () {
    }
}

public Switchboard.Plug get_plug (Module module) {
    debug ("Activating Community Indicators plug");
    return new Indicators.Plug ();
}
