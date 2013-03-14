/* valabatterybattery.vala
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
 
namespace ValaBattery {
    
    public enum BatteryState {
        Charging,
        Discharging,
        Unknown,
        Idle
    }
        
    public class Battery : GLib.Object {
        
        public int percent_left { get; set; default = 0; }
        
        public string time_remaining { get; set; default = ""; }
        
        public BatteryState state { get; set; default = BatteryState.Unknown; }

        private string get_acpi_output ()
        {
            string standard_output, standard_error;
            int exit_status;

            try
            {
                Process.spawn_command_line_sync ("/usr/bin/acpi", out standard_output, out standard_error, out exit_status);
            } catch (SpawnError e) {
                stderr.printf ("%s\n", e.message);
            }

            if (standard_output.length <= 0)
            {
                return standard_error;
            }

            return standard_output;
        }

        private void update_battery_info ()
        {
            string acpiOutput = get_acpi_output ();

            string []splittedData = acpiOutput.split (":" , 2);
            if (splittedData.length > 1)
            {
                
                string []batteryInfo = splittedData[1].split ("," , 3);
                if (batteryInfo.length == 2)
                {
                    
                    if (batteryInfo[0]._strip() == "Unknown" || batteryInfo[0]._strip () == "Full")
                    {
                        state = BatteryState.Idle;
                    }
                    
                    string pctLine = batteryInfo[1]._strip ();
                    percent_left = int.parse (pctLine[0:pctLine.length - 1]);
                } else if (batteryInfo.length == 3) {
                    if (batteryInfo[0]._strip () == "Charging")
                    {
                        state = BatteryState.Charging;
                    } else if (batteryInfo[0]._strip () == "Discharging") {
                        state = BatteryState.Discharging;
                    } else {
                        state = BatteryState.Unknown;
                    }

                    string pctLine = batteryInfo[1]._strip ();
                    percent_left = int.parse (pctLine[0:pctLine.length - 1]);
                    time_remaining = batteryInfo[2];
                }
            } else {
                percent_left = 0;
                time_remaining = "";
                state = BatteryState.Unknown;
            }
        }

        public void update ()
        {
            update_battery_info ();
        }
        
    }
}
