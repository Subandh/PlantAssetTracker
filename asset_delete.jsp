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
if (idStr == null || idStr.trim().isEmpty()) { response.sendRedirect("dashboard.jsp"); return; }

try (Connection con = getConn();
     PreparedStatement ps = con.prepareStatement("DELETE FROM assets WHERE id=?")) {
  ps.setInt(1, Integer.parseInt(idStr));
  ps.executeUpdate();
  response.sendRedirect("dashboard.jsp");
} catch (Exception e) {
%>
  <p style="color:red;">Error: <%= e.getMessage() %></p>
  <p><a href="dashboard.jsp">Back</a></p>
<%
}
%>