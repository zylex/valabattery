using GLib;
using Gtk;
public class ValaBattery: GLib.Object
{
	public static int main(string[] args)
	{
		stdout.printf("** creating valabattery tray icon\n");
		Gtk.init(ref args);
		TrayIcon m_icon = new TrayIcon();
		m_icon.Update();

		var time = new TimeoutSource(2000);

		time.set_callback(() =>
		{
			m_icon.Update();
			return true;
		});

		time.attach(null);
		Gtk.main();
		return 0;
	}
}
