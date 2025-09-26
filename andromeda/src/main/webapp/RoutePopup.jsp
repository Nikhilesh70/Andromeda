<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    String username = (String) session.getAttribute("username");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%> 
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>AmxRoute Popup</title>
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
 .info-box {
    display: flex;
    justify-content: space-between;
    padding: 0px;
    border: 1px solid #000;
    border-radius: 4px;
  }
  .info-box div {
    flex: 1;
    padding: 5px;
    text-align: center;
  }
  .info-box div:not(:last-child) {
    border-right: 1px solid #000; 
  }
  #partsTable, #routeTable {
  border-collapse: collapse; 
  table-layout: fixed;     
}
#partsTable th, #partsTable td, #routeTable th, #routeTable td {
  padding: 0px 0px; 
  white-space: nowrap; 
  text-align: left;
}
table.properties {
  width: 100%;
  border-collapse: collapse;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: Arial, sans-serif;
  margin: 0 auto;
}

table.properties th,
table.properties td {
  padding: 2px 6px;
  border: 1px solid #ddd; 
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 70px; 
  text-align: left;
}
#detailsTable {
   width: 70%;
   border-collapse: collapse;
   margin-top: 10px;
}
th, td {
   border: 1px solid #dee2e6;
   padding: 12px;
   text-align: left;
   font-wrap-mode:nowrap;
}
th {
background-color: #f8f9fa;
width: 70px;
forn-wrap-mode:nowrap;
}
table.table {
  font-size: 14px; 
  max-width:70%; 
  margin: 0 auto; 
}

#partsTable th, #partsTable td, #routeTable th, #routeTable td {
  padding: 4px 6px; 
  white-space: nowrap;
  text-align: left;
}

#detailsTable th, #detailsTable td {
  padding: 6px 8px; 
  font-size: 12px; 
}
.container {
  padding-top: 10px;s
}

</style>
</head>
<body>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg blue-toolbar position-relative">
  <div class="container-fluid">
    <div class="navbar-brand d-flex align-items-center">
      <img src="rr.png" alt="Logo" />
      <b class="ms-2">ANDROMEDA</b>
    </div>
  </div>
</nav>
    <div class="section-label">PartControlTable</div>
    <table class="table table-bordered mt-2" id="partsTable">
    <thead>
        <tr>
            <th>Name</th>
            <th>Supertype</th>
        </tr>
    </thead>
    <tbody>
    </tbody>
</table>
    <div class="section-label">Route Data
    </div>
<table class="table table-bordered mt-2" id="routeTable">
<thead>
    <tr>
        <th>Name</th>
        <th>Supertype</th>
    </tr>
</thead>
<tbody>
</tbody>
</table>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const loginUser = "<%= username %>";
</script>
<script>
$(document).ready(function () {
    const objectId = new URLSearchParams(window.location.search).get('name');
    if (!objectId) {
        $('#errorMessage').text("No 'name' (ObjectId) parameter found in the URL.");
        return;
    }

    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getinfospc',
        method: 'GET',
        data: { objectId: objectId },
        dataType: 'json',
        success: function (data) {
            if (!data || $.isEmptyObject(data)) {
                $('#errorMessage').text("No details found for ObjectId: " + objectId);
                return;
            }

            const name = data.name;
            const supertype = data.supertype;

            const row = '<tr>' +
                        '<td><a href="javascript:void(0);" class="part-link" onclick="openPopupPage(\'' + encodeURIComponent(data.objectid) + '\')">' + name + '</a></td>' +
                        '<td>' + supertype + '</td>' +
                        '</tr>';
            $('#partsTable tbody').append(row);
        },
        error: function (xhr) {
            console.error("Error fetching data:", xhr);
            $('#errorMessage').text("Error fetching part details.");
        }
    });

    $.ajax({
        url: 'http://localhost:8080/andromeda/api/datafetchservice/getconnectedroute',
        method: 'GET',
        data: { objectid: objectId },
        dataType: 'json',
        success: function (data) {
            if (Array.isArray(data) && data.length > 0) {
            	data.forEach(function (route) {

            	    const routeName = route.name || "Unknown";
            	    const supertype = route.supertype || "Unknown";
            	    const routeId = route.objectid || route.routeId || ""; 

            	    if (!routeId) return; 

            	    const row = '<tr>' +
            	        '<td><a href="javascript:void(0);" class="route-link" onclick="openRoutePopupPage(\'' + encodeURIComponent(routeId) + '\')">' + routeName + '</a></td>' +
            	        '<td>' + supertype + '</td>' +
            	        '</tr>';
            	    $('#routeTable tbody').append(row);
            	});

            } else {
                $('#errorMessage').text("No connected routes found for ObjectId: " + objectId);
            }
        },
        error: function (xhr) {
            console.error("Error fetching connected routes:", xhr);
            $('#errorMessage').text("Error fetching connected route details.");
        }
    });

});
const allPopups = [];

function openRoutePopupPage(objectId) {
    const url = "RouteProperties.jsp?name=" + encodeURIComponent(objectId);
    const popup = window.open(
        url,
        'RouteProperties',
        'width=850,height=600,left=100,top=100,resizable=yes'
    );
    if (popup) {
        allPopups.push(popup);
    }
}

function openPopupPage(objectId) {
    const url = "RouteProperties.jsp?name=" + encodeURIComponent(objectId);
    const popup = window.open(
        url,
        'RouteProperties',
        'width=800,height=550,left=100,top=100,resizable=yes'
    );
    if (popup) {
        allPopups.push(popup);
    }
}

function closeAllPopups() {
    allPopups.forEach(popup => {
        if (popup && !popup.closed) {
            popup.close();
        }
    });
    allPopups.length = 0; 
}
</script>
</body>
</html>
