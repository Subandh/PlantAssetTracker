<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jspf" %>
<%@ page import="java.sql.*" %>

<%
Boolean loggedIn = (Boolean) session.getAttribute("loggedIn");
if (loggedIn == null || !loggedIn) { response.sendRedirect("login.jsp"); return; }

String role = (String) session.getAttribute("role");
if ("reader".equals(role)) {
    out.println("Access Denied");
    return;
}

String idStr = request.getParameter("id");
String code = request.getParameter("asset_code");
String name = request.getParameter("name");
String status = request.getParameter("status");
String lastM = request.getParameter("last_maintenance");
String nextM = request.getParameter("next_maintenance");

try (Connection con = getConn()) {

  if (idStr == null || idStr.trim().isEmpty()) {
    String sql = "INSERT INTO assets(asset_code, name, status, last_maintenance, next_maintenance) VALUES (?,?,?,?,?)";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, code);
      ps.setString(2, name);
      ps.setString(3, status);

      if (lastM == null || lastM.isEmpty()) ps.setNull(4, Types.DATE);
      else ps.setDate(4, java.sql.Date.valueOf(lastM));

      if (nextM == null || nextM.isEmpty()) ps.setNull(5, Types.DATE);
      else ps.setDate(5, java.sql.Date.valueOf(nextM));

      ps.executeUpdate();
    }
  } else {
    String sql = "UPDATE assets SET name=?, status=?, last_maintenance=?, next_maintenance=? WHERE id=?";
    try (PreparedStatement ps = con.prepareStatement(sql)) {
      ps.setString(1, name);
      ps.setString(2, status);

      if (lastM == null || lastM.isEmpty()) ps.setNull(3, Types.DATE);
      else ps.setDate(3, java.sql.Date.valueOf(lastM));

      if (nextM == null || nextM.isEmpty()) ps.setNull(4, Types.DATE);
      else ps.setDate(4, java.sql.Date.valueOf(nextM));

      ps.setInt(5, Integer.parseInt(idStr));
      ps.executeUpdate();
    }
  }

  response.sendRedirect("dashboard.jsp");
} catch (Exception e) {
%>
  <p style="color:red;">Error: <%= e.getMessage() %></p>
  <p><a href="dashboard.jsp">Back</a></p>
<%
}
%>