/* valabatterytrayicon.vala
 *
 * Copyright (C) 2012  Tom Englund
 * Copyright (C) 2013  Zylex
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Tom Englund <tomenglund26@gmail.com>
 * 	Zylex <zylex.stk@gmail.com>
 */
 
using Gtk;
using Gdk;
using Notify;

namespace ValaBattery
{
    
    public class TrayIcon : Gtk.Window
    {
        
        private StatusIcon tray_icon;
        private Battery battery;
        private Configuration configuration;
        private string last_pixbuf;
        private bool low_battery_notified;
        private bool hibernate_notified;
        private Gtk.Menu menu;  

        public TrayIcon ()
        {
            low_battery_notified = false;
            hibernate_notified = false;
            battery = new Battery ();
            configuration = new Configuration ();
            Notify.init ("ValaBattery");

            try
            {
                last_pixbuf = "Icons/b_error.png";
                tray_icon = new StatusIcon.from_pixbuf (new Pixbuf.from_file(last_pixbuf));
                tray_icon.set_tooltip_text ("Pct:" + battery.percent_left.to_string() + "% " + battery.time_remaining);
                tray_icon.set_visible (true);
                create_menu ();
                tray_icon.popup_menu.connect (menu_popup);
            } catch (Error e) {
                stderr.printf ("%s\n", e.message);
            }
        }

        public void update ()
        {
            battery.update ();
            update_tooltip ();
            update_pixbuf ();
            check_hibernate ();
        }

        private void check_hibernate ()
        {
            if (battery.state == BatteryState.Discharging)
            {
                if (low_battery_notified == false && configuration.hibernate_level < battery.percent_left && battery.percent_left <= configuration.notify_level)
                {

                    show_notification ("Only " + battery.percent_left.to_string () + "% battery left!", "Your computer will soon go to sleep.", "xfpm-battery-empty");
                    low_battery_notified = true;

                }
                if (battery.percent_left <= configuration.hibernate_level)
                {
                    if (hibernate_notified == false)
                    {
                        show_notification ("Battery is now empty!!!", "Your computer will now go to sleep.", "xfpm-battery-empty");
                        hibernate_notified = true;
                    }
                    string standard_output, standard_error;
                    int exit_status;
                    try
                    {
                        Process.spawn_command_line_sync (configuration.hibernate_command, out standard_output, out standard_error, out exit_status);
                        hibernate_notified = false;
                        low_battery_notified = false;
                    } catch (SpawnError e) {
                        stderr.printf ("%s\n", e.message);
                    }
                }
            }

            if (hibernate_notified == true && battery.percent_left > configuration.hibernate_level)
            {
                hibernate_notified = false;
            } else if (low_battery_notified == true && battery.percent_left > configuration.notify_level) {
                low_battery_notified = false;
            }
        }

        private void update_tooltip ()
        {
            if(battery.state == BatteryState.Charging)
            {
                tray_icon.set_tooltip_text("BatteryPct: " + battery.percent_left.to_string() + "% Charging " + battery.time_remaining + ".");
            } else if(battery.state == BatteryState.Discharging) {
                tray_icon.set_tooltip_text("BatteryPct: " + battery.percent_left.to_string() + "% Discharging " + battery.time_remaining + ".");
            } else if(battery.state == BatteryState.Idle) {
                tray_icon.set_tooltip_text("BatteryPct: " + battery.percent_left.to_string() + "% Using AC power.");
            } else if(battery.state == BatteryState.Unknown) {
                tray_icon.set_tooltip_text("No Battery found.");
            }
        }

        private void update_pixbuf ()
        {
            if(battery.state == BatteryState.Charging)
            {
                set_pixbuf("Icons/b_ch_" + battery.percent_left.to_string() + ".png");
            } else if(battery.state == BatteryState.Discharging) {
                set_pixbuf("Icons/b_dch_" + battery.percent_left.to_string() + ".png");
            } else if(battery.state == BatteryState.Idle) {
                set_pixbuf("Icons/b_full.png");
            } else if(battery.state == BatteryState.Unknown) {
                set_pixbuf("Icons/b_error.png");
            }
        }

        private void set_pixbuf (string icon)
        {
            if(last_pixbuf != icon)
            {
                try
                {
                    tray_icon.set_from_pixbuf(new Pixbuf.from_file(icon));
                    last_pixbuf = icon;
                } catch(Error e) {
                    stderr.printf("%s\n", e.message);
                }
            }
        }

        private void show_notification (string title, string content, string iconType)
        {
            var notification = new Notification (title, content, iconType);
            notification.show ();
        }

        public void create_menu () {
            menu = new Gtk.Menu ();
            var menu_about = new ImageMenuItem.from_stock (Stock.ABOUT, null);
            menu_about.activate.connect (about_clicked);
            menu.append (menu_about);
            var menu_quit = new ImageMenuItem.from_stock (Stock.QUIT, null);
            menu_quit.activate.connect (Gtk.main_quit);
            menu.append (menu_quit);
            menu.show_all ();
        }

        private void menu_popup (uint button, uint time) {
            menu.popup (null, null, null, button, time);
        }

        private void about_clicked () {
            var about = new AboutDialog ();
            about.set_version ("2.0.0");
            about.set_program_name ("Vala Battery");
            about.set_comments ("Battery monitor written in Vala.");
            about.set_copyright ("GPL");
            about.run ();
            about.hide ();
        }
    }
}
