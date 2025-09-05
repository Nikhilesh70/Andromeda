<!DOCTYPE html>
<html lang="en">
<head> 
	<meta charset="UTF-8">
	<title> Life Cycle</title>
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
    <style>
    	 <style>
        body {
            font-family: Arial, sans-serif;
            padding: 20px;
            background-color: white;
        }
        h2 {
            text-align: center;
            margin-bottom: 20px;
        }
       
        .error {
            color: red;
            margin-top: 20px;
            text-align: center;
        }
        #loadingSpinner {
            border: 4px solid #f3f3f3;
            border-top: 4px solid #3498db;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 40px auto 10px auto;
            display: none;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        .nav-tabs {
            margin-bottom: 20px;
        }
        .nav-tabs .nav-link.active {
            background-color: #e9ecef;
            font-weight: bold;
        }
        .state-label {
            padding: 10px 20px;
            margin: 5px;
            cursor: pointer;
            border: 1px solid #dee2e6;
            display: inline-block;
            border-radius: 5px;
            color: white;
        }
        #inWorkLabel {
            background-color: #5bc0de; 
        }
        #frozenLabel {
            background-color: #6c757d; 
        }
        #approvedLabel {
            background-color: #28a745; 
        }
        #releasedLabel {
            background-color: #ffc107; 
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
    </style>
</head>
<body class="container mt-4">
    <ul class="nav nav-tabs">
        <li class="nav-item">
            <a class="nav-link" href="Partcontroldetails.jsp?name=<%= request.getParameter("name") %>">PC-Properties</a>
        </li>
        <li class="nav-item">
            <a class="nav-link " href="Partcontrolhistory.jsp?name=<%= request.getParameter("name") %>">History</a>
        </li>
        <li class="nav-item">
            <a class="nav-link active" href="Partlifecycle.jsp?name=<%= request.getParameter("name") %>">Lifecycle</a>
        </li>
         <li class="nav-item">
        <a class="nav-link" href="Partcontrolmanagement.jsp?name=<%= request.getParameter("name") %>">Part Management</a>
    </li>
    </ul>
    <div id="loadingSpinner"></div>
    <div id="errorMessage" style="display:none;"></div>
    
    <div class="d-flex flex-wrap mt-3">
        <div id="inWorkLabel" class="state-label">InWork</div>
        <div id="frozenLabel" class="state-label">Frozen</div>
        <div id="approvedLabel" class="state-label">Approved</div>
        <div id="releasedLabel" class="state-label">Released</div>
    </div>
        <div id="stateMessages"></div>
    
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
function getQueryParam(param) {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get(param);
}

function displayStateMessage(state) {
    const messageContainer = $("#stateMessages");
    messageContainer.empty(); 
    messageContainer.append(`<div class="message">Part has been moved to the ${state} state.</div>`);
}

function updateState(state) {
    const partID = getQueryParam("name"); 
    $.ajax({
        url: 'http://localhost:8080/andromeda/api/updatePartState',
        method: 'POST',
        data: { partID, newState: state },
        dataType: 'json',
        success: function(response) {
            if (response.status === "success") {
                displayStateMessage(state);
            } else {
                alert("Failed to update state: " + response.message);
            }
        },
        error: function() {
            alert("Error updating part state.");
        }
    });
}

$(document).ready(function() {

    $('#inWorkLabel').on('click', function() {
        updateState('InWork');
    });

    $('#frozenLabel').on('click', function() {
        updateState('Frozen');
    });

    $('#approvedLabel').on('click', function() {
        updateState('Approved');
    });

    $('#releasedLabel').on('click', function() {
        updateState('Released');
    });
});
	
</script>
</body>
</html>