/* valabatterymain.vala
 *
 * Copyright (C) 2006-2010  Jürg Billeter
 * Copyright (C) 2006-2008  Raffaele Sandrini
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

namespace ValaBattery {
    
    public class ValaBattery: GLib.Object {

        public static int main(string[] args) {
            stdout.printf("** creating valabattery tray icon\n");
            Gtk.init(ref args);
            TrayIcon icon = new TrayIcon();
            icon.update();

            var time = new TimeoutSource(2000);

            time.set_callback(() =>
                {
                    icon.update();
                    return true;
                });

            time.attach(null);
            Gtk.main();
            return 0;
        }
    }
}
