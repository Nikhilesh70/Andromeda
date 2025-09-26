<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    String username = (String) session.getAttribute("username");
    if (userAccess == null) {
        userAccess = "Admin";
    }
    String currentState = (String) session.getAttribute("state");
    if (currentState == null) {
        currentState = "Inactive"; 
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Route State Page</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
<style>
  .blue-toolbar {
    background-color: #0072CE;
    color: white;
    padding: 0.25rem 1rem;
    min-height: 50px;
  }
  .navbar-brand {
    color: white;
    font-size: 1.1rem;
  }
  .navbar-brand img {
    border-radius: 60px;
    width: 40px;
    height: 40px;
  }
  
  .container {
    padding-top: 20px;
  }

  .state-flow {
    display: flex;
    align-items: center;
    gap: 15px;
    flex-wrap: wrap;
  }

  .state-box {
    min-width: 120px;
    text-align: center;
    padding: 12px 20px;
    border-radius: 6px;
    color: white;
    font-weight: bold;
    font-size: 14px;
    box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    cursor: default;
    user-select: none;
    transition: box-shadow 0.3s ease, border 0.3s ease;
  }

  .state-box.inactive {
    background-color: #6c757d; 
  }

  .state-box.active {
    background-color: #007bff; 
  }

  .state-box.completed {
    background-color: #28a745; 
  }

  .state-box.current {
    border: 3px solid #222;
    box-shadow: 0 0 12px rgba(0,0,0,0.5);
  }

  .arrow {
    font-size: 24px;
    color: #888;
    margin: 0 8px;
    user-select: none;
  }
</style>
</head>
<body>
<nav class="navbar navbar-expand-lg blue-toolbar position-relative">
  <div class="container-fluid">
    <div class="navbar-brand d-flex align-items-center text-white">
      <img src="rr.png" alt="Logo" />
      <b class="ms-2">ANDROMEDA</b>
    </div>
  </div>
</nav>
<div class="container">
  <div class="gray-toolbar">
  <h6 class="m-0">Route State</h6>
</div>
  <div class="state-flow mt-4">
    <div class="state-box inactive <%= "Inactive".equals(currentState) ? "current" : "" %>">InActive</div>
    <div class="arrow">➝</div>
    <div class="state-box active <%= "Active".equals(currentState) ? "current" : "" %>">Active</div>
    <div class="arrow">➝</div>
    <div class="state-box completed <%= "Completed".equals(currentState) ? "current" : "" %>">Completed</div>
  </div>
</div>

</body>
</html>
