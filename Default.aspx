<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="InstanaTestApp.DefaultPage" %>
<!DOCTYPE html>
<html>
<head runat="server">
    <title>Test App</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        .status-table { border-collapse: collapse; width: 100%; max-width: 600px; }
        .status-table th, .status-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        .status-table th { background-color: #f2f2f2; }
        .ok { color: green; font-weight: bold; }
        .err { color: red; font-weight: bold; }
        .warn { color: orange; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Test App</h1>
    <p>Aplicacion ASP.NET Framework 4.5 / IIS 8.5</p>
    <p>App Name: <asp:Label ID="lblAppName" runat="server" /></p>
    
    <table class="status-table">
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
</body>
</html>