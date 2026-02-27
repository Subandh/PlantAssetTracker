<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jspf" %>
<%@ page import="java.sql.*, java.time.*" %>

<%
Boolean loggedIn = (Boolean) session.getAttribute("loggedIn");
if (loggedIn == null || !loggedIn) {

    String u = request.getParameter("username");
    String p = request.getParameter("password");

    if (u == null || p == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    try (Connection con = getConn();
         PreparedStatement ps = con.prepareStatement(
             "SELECT id, role FROM admins WHERE username=? AND password=?")) {

        ps.setString(1, u);
        ps.setString(2, p);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                session.setAttribute("loggedIn", true);
                session.setAttribute("adminUser", u);
                session.setAttribute("role", rs.getString("role"));
            } else {
                request.setAttribute("err", "Invalid username/password");
                RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                rd.forward(request, response);
                return;
            }
        }
    }
}

String adminUser = (String) session.getAttribute("adminUser");
String role = (String) session.getAttribute("role");
boolean reader = "reader".equalsIgnoreCase(role);

String filter = request.getParameter("filter");
int riskDays = 15;

LocalDate today = LocalDate.now();
LocalDate riskUntil = today.plusDays(riskDays);

int totalCount = 0;
int downCount = 0;
int computedRiskCount = 0;

try (Connection con = getConn();
     PreparedStatement ps = con.prepareStatement(
         "SELECT status, next_maintenance FROM assets")) {

    try (ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
            totalCount++;

            String st = rs.getString("status");
            if ("DOWN".equalsIgnoreCase(st)) downCount++;

            Date nmDate = rs.getDate("next_maintenance");
            if (nmDate != null) {
                LocalDate nm = nmDate.toLocalDate();
                if (nm.isBefore(today) || !nm.isAfter(riskUntil)) {
                    computedRiskCount++;
                }
            }
        }
    }
} catch (Exception e) {
}
%>

<!DOCTYPE html>
<html>
<head>
  <title>PlantAssetTracker - Dashboard</title>

  <style>
    body{font-family:Arial;background:#f4f6f9;margin:0;}
    .top{background:#111827;color:#fff;padding:14px 18px;display:flex;justify-content:space-between;align-items:center;}
    .wrap{padding:18px;max-width:1100px;margin:auto;}
    .btn{display:inline-block;padding:8px 12px;border-radius:8px;background:#2d6cdf;color:#fff;text-decoration:none;margin-right:8px;}
    .btn.gray{background:#6b7280;}
    .btn.red{background:#dc2626;}
    .btn.sm{padding:6px 10px;font-size:13px;border-radius:8px;}
    table{width:100%;border-collapse:collapse;background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 6px 18px rgba(0,0,0,.06);}
    th,td{padding:11px 10px;border-bottom:1px solid #eee;text-align:left;font-size:14px;}
    th{background:#f9fafb;}
    .tag{padding:3px 10px;border-radius:999px;font-size:12px;background:#e5e7eb;display:inline-block;font-weight:700;}
    .risk{background:#fee2e2;color:#7f1d1d;}
    .warn{background:#ffedd5;color:#7c2d12;}
    .ok{background:#dcfce7;color:#065f46;}
    .muted{color:#6b7280;font-size:13px;}
    .cards{display:grid;grid-template-columns:repeat(3,1fr);gap:12px;margin:14px 0 12px;}
    .card{background:#fff;border-radius:12px;padding:12px 14px;box-shadow:0 6px 18px rgba(0,0,0,.06);border:1px solid #e5e7eb;}
    .card .k{font-size:12px;color:#6b7280;font-weight:700;text-transform:uppercase;letter-spacing:.3px;}
    .card .v{font-size:22px;font-weight:800;margin-top:6px;}
    .toolbar{display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:10px;margin-bottom:12px;}
    .roleBadge{margin-left:8px;}
    @media(max-width:850px){ .cards{grid-template-columns:1fr;} }
  </style>
</head>

<body>
  <div class="top">
    <div>
      <b>PlantAssetTracker</b>
      — Welcome, <%= adminUser %>
      <span class="tag roleBadge <%= reader ? "warn" : "ok" %>">
        <%= (role == null ? "UNKNOWN" : role.toUpperCase()) %>
      </span>
      <div class="muted">Computed risk = OVERDUE or Due within <%= riskDays %> days</div>
    </div>
    <div>
      <a class="btn gray" href="logout.jsp">Logout</a>
    </div>
  </div>

  <div class="wrap">

    <div class="cards">
      <div class="card">
        <div class="k">Total Machines</div>
        <div class="v"><%= totalCount %></div>
      </div>
      <div class="card">
        <div class="k">Down</div>
        <div class="v"><%= downCount %></div>
      </div>
      <div class="card">
        <div class="k">Computed At-Risk</div>
        <div class="v"><%= computedRiskCount %></div>
      </div>
    </div>

    <div class="toolbar">
      <div>
        <% if (!reader) { %>
          <a class="btn" href="asset_form.jsp">+ Add Asset</a>
        <% } %>
        <a class="btn gray" href="dashboard.jsp">All Assets</a>
        <a class="btn gray" href="dashboard.jsp?filter=risk">At-Risk (≤ <%= riskDays %> days)</a>
      </div>

      <% if (reader) { %>
        <div class="muted"><b>Reader mode:</b> View only (no edit/delete)</div>
      <% } %>
    </div>

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Asset Code</th>
          <th>Name</th>
          <th>Status</th>
          <th>Last Maintenance</th>
          <th>Next Maintenance</th>
          <th>Computed Risk</th>
          <th>Actions</th>
        </tr>
      </thead>
      <tbody>

<%
String sql = "SELECT * FROM assets ORDER BY id";
if ("risk".equalsIgnoreCase(filter)) {
    sql = "SELECT * FROM assets WHERE next_maintenance IS NOT NULL AND next_maintenance <= ? ORDER BY next_maintenance ASC";
}

try (Connection con = getConn();
     PreparedStatement ps = con.prepareStatement(sql)) {

    if ("risk".equalsIgnoreCase(filter)) {
        ps.setDate(1, java.sql.Date.valueOf(riskUntil));
    }

    try (ResultSet rs = ps.executeQuery()) {
        boolean any = false;

        while (rs.next()) {
            any = true;

            int id = rs.getInt("id");
            String code = rs.getString("asset_code");
            String nm = rs.getString("name");
            String status = rs.getString("status");
            Date lastM = rs.getDate("last_maintenance");
            Date nextM = rs.getDate("next_maintenance");

            String riskLabel = "UNKNOWN";
            String riskClass = "tag";

            if (nextM != null) {
                LocalDate next = nextM.toLocalDate();
                if (next.isBefore(today)) {
                    riskLabel = "OVERDUE";
                    riskClass = "tag risk";
                } else if (!next.isAfter(riskUntil)) {
                    riskLabel = "DUE SOON";
                    riskClass = "tag warn";
                } else {
                    riskLabel = "OK";
                    riskClass = "tag ok";
                }
            }

            String stClass = "tag";
            if ("OK".equalsIgnoreCase(status)) stClass = "tag ok";
            else if ("DOWN".equalsIgnoreCase(status)) stClass = "tag risk";
            else if ("AT_RISK".equalsIgnoreCase(status)) stClass = "tag warn";
%>
        <tr>
          <td><%= id %></td>
          <td><%= code %></td>
          <td><%= nm %></td>
          <td><span class="<%= stClass %>"><%= status %></span></td>
          <td><%= (lastM == null) ? "-" : lastM.toString() %></td>
          <td><%= (nextM == null) ? "-" : nextM.toString() %></td>
          <td><span class="<%= riskClass %>"><%= riskLabel %></span></td>

          <td>
            <% if (!reader) { %>
              <a class="btn sm gray" href="asset_form.jsp?id=<%= id %>">Edit</a>
              <a class="btn sm red" href="asset_delete.jsp?id=<%= id %>"
                 onclick="return confirm('Delete this asset?')">Delete</a>
            <% } else { %>
              <span class="muted">View Only</span>
            <% } %>
          </td>
        </tr>
<%
        }

        if (!any) {
%>
        <tr><td colspan="8">No records found.</td></tr>
<%
        }
    }
} catch (Exception e) {
%>
    <tr><td colspan="8" style="color:#c00;">Error: <%= e.getMessage() %></td></tr>
<%
}
%>

      </tbody>
    </table>

    <div class="muted" style="margin-top:10px;">
    </div>
  </div>
</body>
</html>