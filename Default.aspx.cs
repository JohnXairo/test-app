using System;
using System.Collections.Generic;
using System.Configuration;
using System.Threading;
using System.Web.UI;

namespace InstanaTestApp
{
    public partial class DefaultPage : Page
    {
        private const string CounterKey = "InstanaActionCounter";

        protected void Page_Load(object sender, EventArgs e)
        {
            lblAppName.Text = ConfigurationManager.AppSettings["AppName"] ?? "InstanaTestApp";

            if (!IsPostBack)
            {
                lblUrl.Text = Request.Url.ToString();
                lblMethod.Text = Request.HttpMethod;
                lblUserAgent.Text = Request.UserAgent ?? "N/A";
                lblIp.Text = Request.UserHostAddress ?? "N/A";
                lblTimestamp.Text = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            }

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

            System.Diagnostics.Trace.TraceInformation("Page_Load ejecutado");
            Console.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] Page_Load");
        }

        protected void BtnTestDb_Click(object sender, EventArgs e)
        {
            LogAction("Database query executed");
            lblDbResult.Visible = true;
            lblDbResult.CssClass = "response-box success";
            lblDbResult.Text = "<strong>✓ Database Query Executed</strong><br />Successfully queried data at " + DateTime.Now.ToString("HH:mm:ss");
            lblDbResult.Style["display"] = "block";
        }

        protected void BtnTestApi_Click(object sender, EventArgs e)
        {
            LogAction("API call executed");
            lblApiResult.Visible = true;
            lblApiResult.CssClass = "response-box success";
            lblApiResult.Text = "<strong>✓ API Call Executed</strong><br />API responded successfully at " + DateTime.Now.ToString("HH:mm:ss");
            lblApiResult.Style["display"] = "block";
        }

        protected void BtnTestLong_Click(object sender, EventArgs e)
        {
            LogAction("Long operation started");
            System.Diagnostics.Stopwatch sw = System.Diagnostics.Stopwatch.StartNew();
            Thread.Sleep(3000);
            sw.Stop();
            lblLongResult.Visible = true;
            lblLongResult.CssClass = "response-box success";
            lblLongResult.Text = "<strong>✓ Long Operation Completed</strong><br />Execution time: " + sw.ElapsedMilliseconds + "ms";
            lblLongResult.Style["display"] = "block";
        }

        protected void BtnTestError_Click(object sender, EventArgs e)
        {
            LogAction("Error handling triggered");
            try
            {
                throw new InvalidOperationException("Test error generated from UI action.");
            }
            catch (Exception ex)
            {
                lblErrorResult.Visible = true;
                lblErrorResult.CssClass = "response-box error";
                lblErrorResult.Text = "<strong>✗ Error Caught</strong><br />Message: " + ex.Message;
                lblErrorResult.Style["display"] = "block";
                System.Diagnostics.Trace.TraceWarning("Simulated exception: " + ex.Message);
            }
        }

        protected void BtnTestCache_Click(object sender, EventArgs e)
        {
            LogAction("Cache read/write executed");
            var cacheValue = "instana-test-" + DateTime.Now.Ticks;
            Application[CounterKey] = cacheValue;
            lblCacheResult.Visible = true;
            lblCacheResult.CssClass = "response-box success";
            lblCacheResult.Text = "<strong>✓ Cache Operation Completed</strong><br />Cache value: " + Application[CounterKey];
            lblCacheResult.Style["display"] = "block";
        }

        protected void BtnTestCounter_Click(object sender, EventArgs e)
        {
            LogAction("Counter incremented");
            int current = 0;
            if (Application[CounterKey] != null)
            {
                int.TryParse(Application[CounterKey].ToString(), out current);
            }

            current++;
            Application[CounterKey] = current.ToString();

            lblCounterResult.Visible = true;
            lblCounterResult.CssClass = "response-box success";
            lblCounterResult.Text = "<strong>✓ Counter Incremented</strong><br />Current value: " + current;
            lblCounterResult.Style["display"] = "block";
        }

        private void LogAction(string actionName)
        {
            System.Diagnostics.Trace.TraceInformation("Action triggered: " + actionName);
            Console.WriteLine($"[{DateTime.Now:yyyy-MM-dd HH:mm:ss.fff}] {actionName}");
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
