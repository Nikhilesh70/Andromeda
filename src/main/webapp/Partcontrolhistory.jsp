<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String userAccess = (String) session.getAttribute("userAccess");
    if (userAccess == null) {
        userAccess = "Admin";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8" />
<title>Part Control History</title>
<style>
  body {
    font-family: Arial, sans-serif;
    margin: 0; padding: 0;
    background: #fff;
    color: #333;
  }

  /* Top Bar Container */
  .topbar {
    display: flex;
    background: #f5f7fa;
    border-bottom: 1px solid #cfd3db;
    padding: 6px 12px;
    font-size: 13px;
    color: #333;
  }

  /* Box styling */
  .topbar > div {
    display: flex;
    align-items: center;
    padding: 6px 12px;
    background: #f9fbfd;
    border: 1px solid #cfd3db;
    border-right: none;
    white-space: nowrap;
  }

  /* Last box has right border */
  .topbar > div:last-child {
    border-right: 1px solid #cfd3db;
  }

  /* Folder Icon Box */
  .folder-box {
    background: #e3e7eb;
    border: 1px solid #d1d6dc;
    width: 28px;
    height: 28px;
    display: flex;
    justify-content: center;
    align-items: center;
    margin-right: 8px;
    flex-shrink: 0;
  }

  .folder-box img {
    width: 16px;
    height: 16px;
  }

  /* Part Number box */
  .part-number {
    font-weight: 700;
    font-size: 14px;
    padding-right: 13px;
    padding-left:13px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  /* Description box */
  .description {
    font-weight: 600;
    font-size: 13px;
    color: #555;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
    margin-right: 12px;
  }

  /* State box */
  .state-box {
    font-weight: 600;
    font-size: 13px;
    color: #333;
    display: flex;
    align-items: center;
    gap: 8px;
    padding-right: 12px;
    border-right: 1px solid #cfd3db;
  }

  .state-label {
    margin-right: 4px;
  }

  /* Buttons styling */
  .btn-submit {
    background-color: #5c8bff;
    border: 1px solid #3f70ff;
    color: white;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-submit:hover {
    background-color: #3f70ff;
  }

  .btn-evaluate {
    background-color: #e5e7ea;
    border: 1px solid #c6cad2;
    color: #555;
    font-size: 12px;
    padding: 4px 14px;
    border-radius: 3px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }

  .btn-evaluate:hover {
    background-color: #c6cad2;
  }

  /* Info box */
  .info-box {
    font-size: 11px;
    color: #666;
    padding-left: 4px;
    line-height: 1.3;
  }

  .info-box strong {
    color: #444;
  }

  /* Adjust spacing between boxes */
  .topbar > div:not(:last-child) {
    margin-right: -1px; /* To collapse adjacent borders */
  }
	
	.vertical-line img {
  height: 20px;  /* Adjust height to make it appear like a line */
  width: 1px;    /* Make it thin like a vertical line */
  margin: 0 10px; /* Space around the line */
}

  /* Container with Sidebar + Main */
  .container {
    display: flex;
    height: calc(100vh - 56px); /* Adjust for topbar height */
    font-size: 13px;
  }

  /* Sidebar */
  /* Sidebar styling */
.sidebar {
  width: 16%;
  background-color: #f8f9fa;
  border-right: 1px solid #ddd;
  padding: 20px;
  font-size: 14px;
  box-sizing: border-box;
   resize: horizontal;
  overflow-y: auto;
  overflow-x: hidden; 
}

.sidebar a {
  display: block;
  padding: 8px;
  color: #333;
  text-decoration: none;
  margin-bottom: 10px;
  border-radius: 4px;
}

.sidebar a:hover {
  background-color: #e3e7ea; 
}

.sidebar a.active {
  background-color:#808080;
  color: white;
   font-weight: bold;
}

/* Main Panel */
.main-panel {
  flex-grow: 1;
  padding: 20px;
  overflow-y: auto;
  font-size: 13px;
  box-sizing: border-box;
}


.container {
  display: flex;
  height: calc(100vh - 56px); 
}

.topbar {
  display: flex;
  background: #f5f7fa;
  border-bottom: 1px solid #cfd3db;
  padding: 6px 12px;
  font-size: 13px;
  color: #333;
}

  .toolbar {
    margin-bottom: 5px;
    padding-left: 2px;
  }
  .toolbar button {
    background: none;
    border: none;
    cursor: pointer;
    margin-right: 6px;
    vertical-align: middle;
    padding: 2px 4px;
  }
  .toolbar button img {
    vertical-align: middle;
    width: 18px;
    height: 18px;
    
  }
  .toolbar i.bi-clock-history {
    color: #9370DB;
    font-size: 24px; /* Increased the size for visibility */
    margin-right: 10px;
}
  .toolbar button:hover {
    background-color: #e3f2fd;
    border-radius: 2px;
  }

table.properties {
  width: 100%; /* full width */
  border-collapse: collapse;
  border: 1px solid #ddd;
  font-size: 16px;
  font-family: Arial, sans-serif;
  margin: 0 auto;
}

table.properties th,
table.properties td {
  padding: 12px 16px;
  border: 1px solid #ddd; /* add borders on all cells */
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 200px; /* label column width */
  text-align: left;
}


  .folder-icon {
    width: 16px;
    height: 16px;
    vertical-align: middle;
    margin-right: 6px;
  }


.properties-container {
  max-height: 600px; 
  overflow-y: auto;
  border: 1px solid #ddd;
  margin-top: 0;
}

  .nav-tabs {
        margin-bottom: 20px;
    }
    #loadingSpinner {
        display: none;
        border: 4px solid #f3f3f3;
        border-top: 4px solid #3498db;
        border-radius: 50%;
        width: 40px;
        height: 40px;
        animation: spin 1s linear infinite;
        margin: 20px auto;
    }
    @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
    }
    #errorMessage {
       
        text-align: center;
        margin-top: 20px;
    }
   #historyTable {
    display: none;
    margin-top: 0;
    font-size: Arial Sans Serif;
}

    .nav-tabs .nav-link.active {
        background-color: #e9ecef !important; 
        font-weight: bold;
        border-color: #dee2e6 #dee2e6 #fff;
    }
    .toolbar {
        display: flex;
        align-items: center;
        margin-bottom: 5px; 
        background-color: #f8f9fa; 
        padding: 8px 12px;
        border-radius: 4px;
        border: 1px solid #ddd;
    }
    .toolbar i.bi-clock-history {
        color: #9370DB;
        font-size: 1.5rem;
        margin-right: 10px;
    }
    .toolbar h4 {
        margin: 0;
        font-weight: 600;
        color: #444;
        font-size: 1rem; 
    }
    #historyTable thead {
    display: none;
} 
.history-icon {
  width: 18px;
  height: 18px;
  margin-right: 8px;
  vertical-align: middle;
}
  .state-box .state-badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-weight: 700;
  font-size: 13px;
  color: white;
  margin-left: 8px;
  user-select: none;
  text-transform: uppercase;
  min-width: 80px;
  text-align: center;
}
.state-badge.InWork {
  background-color: #5bc0de;
}

.state-badge.InApproval {
  background-color: #6c757d;
}

.state-badge.Completed {
  background-color: #28a745;
}

.state-badge.Cancelled {
  background-color: #000000;
  color: #ffffff;
}
 
</style>
</head>
<body>
<div class="topbar">
  <div class="left-section">
    <div class="image-box">
      <img src="https://img.icons8.com/?size=50&id=WECphWgmeM0g&format=png&color=000000" alt="Folder Icon" />
    </div>
   <div class="part-info">
            <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
            <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px;padding-left:13px"></div>
        </div>
    <div class="vertical-line"></div>
  </div>
  <div class="right-section">
    <div class="state-box">
      <span class="state-label">State:</span>
    </div>
    <div class="vertical-line"></div>
    <div class="info-box">
      
    </div>
    <div class="vertical-line"></div>
  </div>
</div>
<div class="container">
  <div class="sidebar">
    <a href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partcontroldetails.jsp">PC-Properties</a>
    <a class="nav-link active" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a>
     <a href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partlifecycle.jsp">LifeCycle</a>
    <a href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partcontrolmanagement.jsp">Part Management</a>
  </div>

  <div class="main-panel">
    <!-- Toolbar -->
   <div class="toolbar">
  		<img src="history.gif" alt="History Icon" class="history-icon" />
  		<h4>History Entries</h4>
	</div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
    <div id="noHistoryMsg" class="text text-center mt-3" style="display:none;"></div>
    <table id="historyTable" class="display table table-striped table-bordered" style="width:100%">
    <thead>
        <tr>
            <th></th> 
        </tr>
    </thead>
    <tbody>

    </tbody>
</table>
  </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
    let dataTable;
    function getQueryParam(param) {
        const urlParams = new URLSearchParams(window.location.search);
        const paramValue = urlParams.get(param);
        return paramValue;
    }

    
    function showLoading(show) {
        $('#loadingSpinner').css('display', show ? 'block' : 'none');
    }

    function showError(message) {
        $('#noHistoryMsg').text(message).show();
        $('#historyTable').hide();
        showLoading(false);
    }
    function displayHistory(historyArray) {
        if (!Array.isArray(historyArray) || historyArray.length === 0) {
            showError("No history found for this ID.");
            return;
        }

        if ($.fn.DataTable.isDataTable('#historyTable')) {
            dataTable.clear().destroy();
        }
        $('#historyTable tbody').empty();

        historyArray.forEach(entry => {
            $('#historyTable tbody').append('<tr><td>' + $('<div>').text(entry).html() + '</td></tr>');
        });

        dataTable = $('#historyTable').DataTable({
            searching: false,
            paging: false,
            ordering: true,
            info: false,
            lengthChange: false
        });

        $('#noHistoryMsg').hide();
        $('#historyTable').show();
        showLoading(false);
    }

    $(document).ready(function () {
        const objectId = getQueryParam('name');  
        if (!objectId) {
            showError("No 'name' (ObjectId) parameter found in the URL.");
            return;
        }
        const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
        
        if (partInfo) {
          $('.part-number').text(partInfo.name || '');
          $('.part-type').text(partInfo.type || '');
          $('.state-box .state-label').remove();
          
          if (partInfo.currentstate) {
      	    $('.state-box .state-label').remove();
      	    const state = partInfo.currentstate;
      	    const badge = $('<span>')
      	        .addClass('state-badge ' + state.replace(/\s/g, ''))
      	        .text(state);
      	    $('<span>')
      	        .addClass('state-label')
      	        .text('State: ')
      	        .append(badge)
      	        .prependTo('.state-box');
      	}
        } else {
          $('.part-number').text('');
          $('.part-type').text('');
        }

        showLoading(true); 
        $.ajax({
            url: 'http://localhost:8080/andromeda/api/datafetchservice/partcontrolhistory',
            method: 'GET',
            data: { objectId: objectId },  
            dataType: 'json',
            success: function (data) {
                if (
                    (data.error && data.error.toLowerCase().includes("no history")) ||
                    (data.message && data.message.toLowerCase().includes("no history"))
                ) {
                    showError(data.message || data.error || "No history found for this ID.");
                } else if (Array.isArray(data.history)) {
                    displayHistory(data.history);
                } else {
                    showError("Unexpected response format.");
                }
            },
            error: function (xhr) {
                let message = "Failed to fetch history.";
                if (xhr.status === 404) {
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response.error && response.error.toLowerCase().includes("no history")) {
                            message = "No history found for this ID.";
                        }
                    } catch (e) {
                    }
                }
                showError(message);
            },
            complete: function () {
                showLoading(false);  
            }
        });
    });
</script>

</body>
</html>
