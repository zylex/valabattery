/* valabatteryconfiguration.vala
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
 
namespace ValaBattery
{

    public class Configuration : GLib.Object
    {

        public int hibernate_level { get; set; default = 5; }
        
        public int notify_level { get; set; default = 7; }
        
        public string hibernate_command { get; set; default = "sudo systemctl hybrid-sleep"; }

        public Configuration()
        {
            var configFile = File.new_for_path("/etc/valabattery.conf");

            read_config_file(configFile);
        }
        
        public Configuration.from_file(string path)
        {
            var file = File.new_for_path (path);
            read_config_file(file);
        }

        private void read_config_file(File file)
        {
            if (!file.query_exists())
            {
                stderr.printf ("File '%s' doesn't exist, using defaults.\n", file.get_path());
            } else {

                try
                {
                    var input = new DataInputStream(file.read());
                    string line;
                    
                    while ( (line = input.read_line(null).strip() ) != null)
                    {
                        if ( !line.has_prefix("#") || !(line.char_count() <= 1) )
                        {
                            string[] option = line.split("=");
                            string optionName = option[0].strip();
                            string optionValue = option[1].strip();
                            
                            if (optionName == "notify") {
                                notify_level = int.parse(optionValue);
                            } else if (optionName == "hibernate") {
                                hibernate_level = int.parse(optionValue);
                            } else if (optionName == "command") {
                                hibernate_command = optionValue;
                            }
                        }
                    }
                } catch (Error e) {
                    error ("%s", e.message);
                }
            }
            print_settings();
        }

        private void print_settings()
        {
            stdout.printf("\nNotify Level = %d\nHibernate Level = %d\nCommand = %s",
                          notify_level,
                          hibernate_level,
                          hibernate_command);
        }
    }
}
