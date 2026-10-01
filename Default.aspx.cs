using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web.UI;

namespace InstanaTestApp
{
    public partial class DefaultPage : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblAppName.Text = ConfigurationManager.AppSettings["AppName"] ?? "InstanaTestApp";

            var rows = new List<object>
            {
                MakeRow(".NET Framework Version", System.Runtime.InteropServices.RuntimeEnvironment.GetSystemVersion(), true),
                MakeRow("CLR Version", Environment.Version.ToString(), true),
                MakeRow("OS", Environment.OSVersion.ToString(), true),
                MakeRow("Machine", Environment.MachineName, true),
                MakeRow("App Pool (APPL_MD_PATH)", Environment.GetEnvironmentVariable("APPL_MD_PATH") ?? "(no disponible fuera de IIS)", true)
            };

            rptEnv.DataSource = rows;
            rptEnv.DataBind();
        }

        private static object MakeRow(string key, string value, bool ok)
        {
            bool missing = string.IsNullOrEmpty(value);
            return new
            {
                Key = key,
                Value = missing ? "(no configurada)" : value,
                Css = ok && !missing ? "ok" : (missing ? "err" : "warn"),
                Status = ok && !missing ? "OK" : (missing ? "FALTA" : "REVISAR")
            };
        }
    }
}