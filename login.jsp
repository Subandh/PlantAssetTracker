<%@ page contentType="text/html; charset=UTF-8" %>
<%
String err = (String) request.getAttribute("err");
%>
<!DOCTYPE html>
<html>
<head>
  <title>PlantAssetTracker - Admin Login</title>
  <style>
    body{font-family:Arial;background:#f4f6f9;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;}
    .card{background:#fff;padding:24px;border-radius:10px;width:360px;box-shadow:0 5px 15px rgba(0,0,0,.1);}
    input,button{width:100%;padding:10px;margin:8px 0;border-radius:6px;border:1px solid #ccc;}
    button{background:#2d6cdf;color:#fff;border:none;cursor:pointer;}
    button:hover{opacity:.95;}
    .err{color:#c00;}
    .muted{color:#666;font-size:13px;}
  </style>
</head>
<body>
  <div class="card">
    <h2>Admin Login</h2>

    <% if (err != null) { %>
      <p class="err"><%= err %></p>
    <% } %>

    <form method="post" action="dashboard.jsp">
      <input type="text" name="username" placeholder="Username" required />
      <input type="password" name="password" placeholder="Password" required />
      <button type="submit">Login</button>
    </form>
  </div>
</body>
</html>