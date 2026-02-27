<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jspf" %>
<%@ page import="java.sql.*" %>

<%
Boolean loggedIn = (Boolean) session.getAttribute("loggedIn");
if (loggedIn == null || !loggedIn) { response.sendRedirect("login.jsp"); return; }

String role = (String) session.getAttribute("role");
if ("reader".equals(role)) {
    response.sendRedirect("dashboard.jsp");
    return;
}

String idStr = request.getParameter("id");
boolean editing = (idStr != null && !idStr.trim().isEmpty());

String code="", name="", status="OK";
String lastM="", nextM="";

if (editing) {
  try (Connection con = getConn();
       PreparedStatement ps = con.prepareStatement("SELECT * FROM assets WHERE id=?")) {
    ps.setInt(1, Integer.parseInt(idStr));
    try (ResultSet rs = ps.executeQuery()) {
      if (rs.next()) {
        code = rs.getString("asset_code");
        name = rs.getString("name");
        status = rs.getString("status");

        Date lm = rs.getDate("last_maintenance");
        Date nm = rs.getDate("next_maintenance");
        lastM = (lm == null) ? "" : lm.toString();
        nextM = (nm == null) ? "" : nm.toString();
      } else {
        response.sendRedirect("dashboard.jsp");
        return;
      }
    }
  }
}
%>

<!DOCTYPE html>
<html>
<head>
  <title><%= editing ? "Edit Asset" : "Add Asset" %></title>
  <style>
    body{font-family:Arial;background:#f4f6f9;padding:18px;margin:0;}
    .card{background:#fff;padding:18px;border-radius:10px;max-width:520px;box-shadow:0 5px 15px rgba(0,0,0,.08);}
    input,select{width:100%;padding:10px;margin:8px 0;border-radius:6px;border:1px solid #ccc;}
    .row{display:flex;gap:10px;}
    .row > div{flex:1;}
    button,a.btn{display:inline-block;padding:10px 12px;border-radius:8px;border:none;background:#2d6cdf;color:#fff;text-decoration:none;cursor:pointer;}
    a.btn.gray{background:#6b7280;}
  </style>
</head>
<body>
  <div class="card">
    <h2><%= editing ? "Edit Asset" : "Add Asset" %></h2>

    <form method="post" action="asset_save.jsp">
      <% if (editing) { %>
        <input type="hidden" name="id" value="<%= idStr %>" />
      <% } %>

      <label>Asset Code</label>
      <input name="asset_code" value="<%= code %>" <%= editing ? "readonly" : "required" %> />

      <label>Name</label>
      <input name="name" value="<%= name %>" required />

      <label>Status</label>
      <select name="status">
        <option value="OK" <%= "OK".equals(status)?"selected":"" %>>OK</option>
        <option value="DOWN" <%= "DOWN".equals(status)?"selected":"" %>>DOWN</option>
        <option value="AT_RISK" <%= "AT_RISK".equals(status)?"selected":"" %>>AT_RISK</option>
      </select>

      <div class="row">
        <div>
          <label>Last Maintenance</label>
          <input type="date" name="last_maintenance" value="<%= lastM %>" />
        </div>
        <div>
          <label>Next Maintenance</label>
          <input type="date" name="next_maintenance" value="<%= nextM %>" />
        </div>
      </div>

      <button type="submit"><%= editing ? "Update" : "Save" %></button>
      <a class="btn gray" href="dashboard.jsp" style="margin-left:8px;">Cancel</a>
    </form>
  </div>
</body>
</html>