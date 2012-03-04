using GLib;
using Gtk;
using Gdk;

public class TrayIcon: Gtk.Window
{
	private enum BatteryState
	{
		Charging,
		Discharging,
		Unknown,
		Idle
	}

	private StatusIcon m_trayIcon;
	private int m_battPct;
	private string m_timeRemaining;
	private BatteryState m_batteryState;
	private string m_lastPixbuf;

	public TrayIcon()
	{
		m_battPct = 0;
		m_timeRemaining = "";
		m_batteryState = BatteryState.Unknown;

		try
		{
			m_lastPixbuf = "Icons/b_error.png";
			m_trayIcon = new StatusIcon.from_pixbuf(new Pixbuf.from_file(m_lastPixbuf));
			m_trayIcon.set_tooltip_text("Pct:" + m_battPct.to_string() + "% " + m_timeRemaining);
			m_trayIcon.set_visible(true);
		}
		catch(Error e)
		{
			stderr.printf("%s\n", e.message);
		}
	}

	public void Update()
	{
		string acpiOutput = GetAcpiOutput();
		ParseAcpi(acpiOutput);
		UpdateTooltip();
		UpdatePixbuf();
	}

	private string GetAcpiOutput()
	{
		string standard_output, standard_error;
		int exit_status;

		try
		{
			Process.spawn_command_line_sync ("/usr/bin/acpi", out standard_output, out standard_error, out exit_status);
		}
		catch (SpawnError e)
		{
			stderr.printf ("%s\n", e.message);
		}

		if(standard_output.length <= 0)
		{
			return standard_error;
		}

		return standard_output;
	}

	private void ParseAcpi(string acpiOutput)
	{
		string []splittedData = acpiOutput.split(":" , 2);
		if(splittedData.length > 1)
		{
			string []batteryInfo = splittedData[1].split("," , 3);
			if(batteryInfo.length == 2)
			{
				if(batteryInfo[0]._strip() == "Unknown")
				{
					m_batteryState = BatteryState.Idle;
				}
				string pctLine = batteryInfo[1]._strip();
				m_battPct = int.parse(pctLine[0:pctLine.length - 1]);
			}
			else if(batteryInfo.length == 3)
			{
				if(batteryInfo[0]._strip() == "Charging")
				{
					m_batteryState = BatteryState.Charging;
				}
				else if(batteryInfo[0]._strip() == "Discharging")
				{
					m_batteryState = BatteryState.Discharging;
				}
				else
				{
					m_batteryState = BatteryState.Unknown;
				}

				string pctLine = batteryInfo[1]._strip();
				m_battPct = int.parse(pctLine[0:pctLine.length - 1]);
				m_timeRemaining = batteryInfo[2];
			}
		}
		else
		{
			m_battPct = 0;
			m_timeRemaining = "";
			m_batteryState = BatteryState.Unknown;
		}
	}

	private void UpdateTooltip()
	{
		if(m_batteryState == BatteryState.Charging)
		{
			m_trayIcon.set_tooltip_text("BatteryPct: " + m_battPct.to_string() + "% Charging " + m_timeRemaining + ".");
		}
		else if(m_batteryState == BatteryState.Discharging)
		{
			m_trayIcon.set_tooltip_text("BatteryPct: " + m_battPct.to_string() + "% Discharging " + m_timeRemaining + ".");
		}
		else if(m_batteryState == BatteryState.Idle)
		{
			m_trayIcon.set_tooltip_text("BatteryPct: " + m_battPct.to_string() + "% Using AC power.");
		}
		else if(m_batteryState == BatteryState.Unknown)
		{
			m_trayIcon.set_tooltip_text("No Battery found.");
		}
	}

	private void UpdatePixbuf()
	{
		if(m_batteryState == BatteryState.Charging)
		{
			SetPixbuf("Icons/b_ch_" + m_battPct.to_string() + ".png");
		}
		else if(m_batteryState == BatteryState.Discharging)
		{
			SetPixbuf("Icons/b_dch_" + m_battPct.to_string() + ".png");
		}
		else if(m_batteryState == BatteryState.Idle)
		{
			SetPixbuf("Icons/b_full.png");
		}
		else if(m_batteryState == BatteryState.Unknown)
		{
			SetPixbuf("Icons/b_error.png");
		}
	}

	private void SetPixbuf(string icon)
	{
		if(m_lastPixbuf != icon)
		{
			try
			{
				m_trayIcon.set_from_pixbuf(new Pixbuf.from_file(icon));
				m_lastPixbuf = icon;
			}
			catch(Error e)
			{
				stderr.printf("%s\n", e.message);
			}
		}
	}
}
