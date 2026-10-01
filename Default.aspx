<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InstanaTestApp.DefaultPage" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Test App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #333; }
        .container { max-width: 900px; margin: 0 auto; background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .ok { color: green; font-weight: bold; }
        .err { color: red; font-weight: bold; }
        .warn { color: orange; font-weight: bold; }
        
        .section { margin-top: 30px; padding: 15px; border: 1px solid #ddd; border-radius: 4px; }
        .section h2 { margin-top: 0; color: #333; }
        
        button { 
            padding: 10px 20px; 
            background-color: #007bff; 
            color: white; 
            border: none; 
            border-radius: 4px; 
            cursor: pointer; 
            font-size: 14px;
            margin-right: 10px;
            margin-bottom: 10px;
        }
        button:hover { background-color: #0056b3; }
        button:active { background-color: #004085; }
        
        .response-box { 
            margin-top: 15px; 
            padding: 10px; 
            background-color: #f0f0f0; 
            border-left: 4px solid #007bff; 
            border-radius: 4px;
        }
        .response-box.success { border-left-color: #28a745; }
        .response-box.error { border-left-color: #dc3545; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="container">
            <h1>Test App - Instana Instrumentation</h1>
            <p>Aplicacion ASP.NET Framework 4.5 / IIS 8.5</p>
            <p>App Name: <asp:Label ID="lblAppName" runat="server" /></p>

            <!-- Seccion: Sistema Info -->
            <div class="section">
                <h2>System Information</h2>
                <table>
                    <tr>
                        <th>Variable</th>
                        <th>Valor</th>
                        <th>Estado</th>
                    </tr>
                    <asp:Repeater ID="rptEnv" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><%# Eval("Key") %></td>
                                <td><%# Eval("Value") %></td>
                                <td class="<%# Eval("Css") %>"><%# Eval("Status") %></td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                </table>
            </div>

            <!-- Seccion: Acciones Simples -->
            <div class="section">
                <h2>Simple Actions (Para Instana Traces)</h2>
                <p>Haz click en los botones para registrar acciones en Instana</p>
                
                <h3>1. Database Query</h3>
                <asp:Button ID="btnTestDb" runat="server" Text="Ejecutar Query DB" OnClick="BtnTestDb_Click" />
                <asp:Label ID="lblDbResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>

                <h3>2. API Call</h3>
                <asp:Button ID="btnTestApi" runat="server" Text="Llamar API" OnClick="BtnTestApi_Click" />
                <asp:Label ID="lblApiResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>

                <h3>3. Long Operation</h3>
                <asp:Button ID="btnTestLong" runat="server" Text="Operación Larga (3s)" OnClick="BtnTestLong_Click" />
                <asp:Label ID="lblLongResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>

                <h3>4. Error Handling</h3>
                <asp:Button ID="btnTestError" runat="server" Text="Simular Error" OnClick="BtnTestError_Click" />
                <asp:Label ID="lblErrorResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>

                <h3>5. Cache Operation</h3>
                <asp:Button ID="btnTestCache" runat="server" Text="Cache Set/Get" OnClick="BtnTestCache_Click" />
                <asp:Label ID="lblCacheResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>

                <h3>6. Counter</h3>
                <asp:Button ID="btnTestCounter" runat="server" Text="Incrementar Contador" OnClick="BtnTestCounter_Click" />
                <asp:Label ID="lblCounterResult" runat="server" CssClass="response-box" style="display: none;"></asp:Label>
            </div>

            <!-- Seccion: Request Info -->
            <div class="section">
                <h2>Current Request Info</h2>
                <table>
                    <tr>
                        <th>Property</th>
                        <th>Value</th>
                    </tr>
                    <tr>
                        <td>Request URL</td>
                        <td><asp:Label ID="lblUrl" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Request Method</td>
                        <td><asp:Label ID="lblMethod" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>User Agent</td>
                        <td><asp:Label ID="lblUserAgent" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Remote IP</td>
                        <td><asp:Label ID="lblIp" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>Timestamp</td>
                        <td><asp:Label ID="lblTimestamp" runat="server" /></td>
                    </tr>
                </table>
            </div>
        </div>
    </form>
</body>
</html>
