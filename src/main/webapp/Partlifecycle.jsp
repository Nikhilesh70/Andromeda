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
<title>Part LifeCycle</title>
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
  height: 20px;  
  width: 1px;   
  margin: 0 10px; 
}

  .container {
    display: flex;
    height: calc(100vh - 56px); 
    font-size: 13px;
  }

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
  border: 1px solid #ddd; 
  vertical-align: middle;
}

table.properties th {
  background: #fafafa;
  font-weight: bold;
  width: 200px; 
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
        #inWorkLabel {
            background-color:#5bc0de; 
        }
        #inapprovalLabel {
            background-color: #6c757d; 
        }
        #completedLabel {
            background-color: #28a745;
        }
        #cancelledLabel {
            background-color:  #ffc107; 
        }
        .state-label:hover {
            background-color: #ddd;
        }
        #stateMessages {
            margin-top: 20px;
            font-size: 16px;
            color: #333;
        }
        #stateMessages .message {
            margin: 10px 0;
        }
        .state-label {
            padding: 10px 20px;
            margin: 5px;
            cursor: pointer;
            display: inline-block;
            border-radius: 5px;
        }
   .lifecycle-icon {
  width: 18px;
  height: 18px;
  margin-right: 8px;
  vertical-align: middle;
}  
.lifecycle-flow {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  margin: 30px 0 20px 0;
  padding: 0 10px;
  flex-wrap: wrap;
}

.state-node {
  padding: 12px 20px;
  background-color: #5bc0de; /* default color */
  color: white;
  border-radius: 6px;
  font-weight: bold;
  font-size: 14px;
  text-align: center;
  min-width: 100px;
  transition: background 0.3s ease;
}

.state-node#stateFrozen { background-color: #6c757d; }
.state-node#stateApproved { background-color: #28a745; }
.state-node#stateReleased { background-color: #ffc107; color: #000; }

.arrow {
  margin: 0 15px;
  font-size: 24px;
  color: #999;
}

.state-node.active {
  border: 3px solid #444;
  box-shadow: 0 0 8px rgba(0,0,0,0.3);
}
@keyframes arrowPulse {
  0% { color: #999; transform: scale(1); }
  50% { color: #007bff; transform: scale(1.5); }
  100% { color: #999; transform: scale(1); }
}

.arrow.animate {
  animation: arrowPulse 0.8s ease-in-out;
}
</style>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
</head>
<body>
<div class="topbar">
  <div class="left-section">
    <div class="image-box">
      <img src="https://img.icons8.com/?size=50&id=WECphWgmeM0g&format=png&color=000000" alt="Folder Icon" />
    </div>
<div class="part-info">
            <div class="part-number" style="font-weight: 700; font-size: 14px;"></div>
            <div class="part-type" style="font-size: 12px; color: #666; margin-top: 2px; padding-left:13px;"></div>
        </div>
    <div class="vertical-line"></div>
  </div>
  <div class="right-section">
    <div class="state-box">
      <span class="state-label">State:</span>
      <button id="submitBtn" class="btn-submit">InWork</button>
      <button id="evaluateBtn" class="btn-evaluate">InApproval</button>
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
    <a class="nav-link" href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a>
     <a href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>" class="nav-link active" data-page="Partlifecycle.jsp">LifeCycle</a>
    <a href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>" class="nav-link" data-page="Partcontrolmanagement.jsp">Part Management</a>
  </div>

  <div class="main-panel">
    <!-- Toolbar -->
    <div class="toolbar">
  		<img src="lifecycle.gif" alt="Lifecycle Icon" class="lifecycle-icon" />
  		<h4>Life Cycle</h4>
	</div>
    <div class="lifecycle-flow">
  <div class="state-node" id="stateInWork" data-state="InWork" title="Click to change to 'In Work'">In Work</div>
  <div class="arrow" id="arrow-InWork-In Approval">➝</div>
  <div class="state-node" id="stateInApproval" data-state="In Approval" title="Click to change to 'Frozen'">In Approval</div>
  <div class="arrow" id="arrow-In Approval-Completed">➝</div>
  <div class="state-node" id="stateCompleted" data-state="Completed" title="Click to change to 'Approved'">Completed</div>
  <div class="arrow" id="arrow-Completed-Cancelled">➝</div>
  <div class="state-node" id="stateCancelled" data-state="Cancelled" title="Click to change to 'Released'">Cancelled</div>
</div>
        <div id="stateMessages"></div>
    <div id="loadingSpinner"></div>
    <div id="errorMessage"></div>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script>
function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

function showMessage(msg, isError = false) {
    const container = $("#stateMessages");
    container.text(msg);
    container.css("color", isError ? "red" : "green");
}

function setLoading(loading) {
    if (loading) {
        $("#loadingSpinner").show();
        $("#nextStateBtn").prop("disabled", true);
        $("#errorMessage").text("");
    } else {
        $("#loadingSpinner").hide();
        $("#nextStateBtn").prop("disabled", false);
    }
}
function fetchStateOnly(objectId) {
    setLoading(true);
    $.ajax({
    	url: 'http://localhost:8080/andromeda/api/datafetchservice/updatestate/' + encodeURIComponent(objectId),
        type: 'GET',
        dataType: 'json',
        success: function(response) {
            setLoading(false);
            if(response.currentState) {
                $("#currentState").text(response.currentState);
                highlightCurrentState(response.currentState); 
            } else {
                $("#currentState").text("Unknown");
            }
        },
        error: function() {
            setLoading(false);
            $("#currentState").text("Error fetching state");
        }
    });
}

$(document).ready(function() {
    const objectId = getQueryParam("name");
	const partInfo = JSON.parse(sessionStorage.getItem('partInfo'));
	 if (partInfo) {
         $('.part-number').text(partInfo.name || '');
         $('.part-type').text(partInfo.type || '');
         const icon = (partInfo.type && partInfo.type.toLowerCase() === 'fastener') 
             ? 'https://img.icons8.com/?size=50&id=20544&format=png&color=000000' 
             : 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000';

         $('#typeIcon').attr('src', icon);

         $('.state-box .state-label').remove();
         if (partInfo.state) {
             $('<span>')
                 .addClass('state-label')
                 .text('State: ' + partInfo.state)
                 .prependTo('.state-box');
         }
     } else {
         $('.part-number').text('');
         $('.part-type').text('');
         $('#typeIcon').attr('src', 'https://img.icons8.com/?size=50&id=OCre7GSjDUBi&format=png&color=000000');
         $('.state-box .state-label').remove();
     }
    if (!objectId) {
        $("#errorMessage").text("No objectId provided in URL");
        $("#nextStateBtn").prop("disabled", true);
        $("#currentState").text("-");
        return;
    }
    $("#currentState").text("Loading...");
    setLoading(false);

    function highlightCurrentState(state) {
    	  $('.state-node').removeClass('active');
    	  $('.state-node').each(function () {
    	    if ($(this).data('state').toLowerCase() === state.toLowerCase()) {
    	      $(this).addClass('active');
    	    }
    	  });
    	}
    
    $('.state-node').on('click', function () {
        const selectedState = $(this).data('state');
        const objectId = getQueryParam("name");

        if (!objectId || !selectedState) return;

        setLoading(true);

        $.ajax({
            url: 'http://localhost:8080/andromeda/api/datafetchservice/updatestate/' +encodeURIComponent(objectId),
            type: 'PUT',
            contentType: "application/json",
            data: JSON.stringify({ state: selectedState }),
            success: function(response) {
                setLoading(false);
                highlightCurrentState(selectedState);
                showMessage("State successfully changed to " + selectedState);
            },
            error: function(xhr) {
                setLoading(false);
                $("#errorMessage").text("Failed to change state: " + xhr.responseText);
            }
        });
    });
    $("#nextStateBtn").on("click", function() {
        setLoading(true);
        $.ajax({
        	url: 'http://localhost:8080/andromeda/api/datafetchservice/updatestate/' +encodeURIComponent(objectId),
            type: 'PUT',
            contentType: "application/json",
            success: function(response) {
                setLoading(false);
                if (response.newState) {
                    $("#currentState").text(response.newState);
                    highlightCurrentState(response.newState);
                    showMessage("State updated to " + response.newState);
                } else if (response.message) {
                    showMessage(response.message);
                } else {
                    showMessage("State updated");
                }
            },
            error: function(xhr) {
                setLoading(false);
                if(xhr.status === 404) {
                    $("#errorMessage").text("Part not found with objectId: " + objectId);
                } else {
                    $("#errorMessage").text("Error updating state: " + xhr.responseText);
                }
            }
        });
    });
});
</script>
</body>
</html>