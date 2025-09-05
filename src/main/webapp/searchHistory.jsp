<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<title>Part History</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css" rel="stylesheet">

<style>
    body {
        padding: 20px;
        font-family: Arial, sans-serif;
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
        color: red;
        text-align: center;
        margin-top: 20px;
    }
    #historyTable {
        display: none;
        margin-top: 0; 
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
    
</style>
</head>
<body class="container">

<ul class="nav nav-tabs">
    <li class="nav-item">
        <a class="nav-link" href="Properties.jsp?name=<%= request.getParameter("name") %>">Part Properties</a>
    </li>
    <li class="nav-item"><a class="nav-link active" href="searchHistory.jsp?name=<%= request.getParameter("name") %>">History</a></li>
    <li class="nav-item">
        <a class="nav-link" href="Lifecycle.jsp?name=<%= request.getParameter("name") %>">Lifecycle</a>
    </li>
     <li class="nav-item">
        <a class="nav-link" href="ControlManagement.jsp?name=<%= request.getParameter("name") %>">ControlManagement</a>
    </li>
</ul>

<!-- Toolbar directly above the table -->
<div class="toolbar">
    <i class="bi bi-clock-history"></i>
    <h4>History Entries</h4>
</div>

<div id="loadingSpinner"></div>
<div id="errorMessage"></div>

<table id="historyTable" class="display table table-striped table-bordered" style="width:100%">
    <thead>
        <tr><th></th></tr> <!-- empty header for structure -->
    </thead>
    <tbody></tbody>
</table>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>

<script>
    let dataTable;

    function getQueryParam(param) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(param);
    }

    function showLoading(show) {
        $('#loadingSpinner').css('display', show ? 'block' : 'none');
    }

    function showError(msg) {
        $('#errorMessage').text(msg).show();
        $('#historyTable').hide();
        showLoading(false);
    }

    function escapeHtml(text) {
        return $('<div>').text(text).html();
    }

    function displayHistory(historyText) {
        console.log("Raw historyText:", historyText);

        if (typeof historyText !== 'string' || historyText.trim() === '') {
            showError("No valid history entries found.");
            return;
        }

        const entries = historyText.split('|').map(e => e.trim()).filter(e => e !== '');

        if (entries.length === 0) {
            showError("No valid history entries found.");
            return;
        }

        if ($.fn.DataTable.isDataTable('#historyTable')) {
            dataTable.clear().destroy();
        }

        $('#historyTable tbody').empty();

        entries.forEach(entry => {
            $('#historyTable tbody').append('<tr><td>' + escapeHtml(entry) + '</td></tr>');
        });

        dataTable = $('#historyTable').DataTable({
            searching: false,
            paging: false,
            ordering: false,
            info: false,
            lengthChange: false
        });

        $('#errorMessage').hide();
        $('#historyTable').show();
        showLoading(false);

        console.log("Table displayed with entries.");
    }

    $(document).ready(function () {
        const objectId = getQueryParam('name');

        if (!objectId) {
            showError("No 'name' parameter found in URL.");
            return;
        }

        showLoading(true);

        $.ajax({
            url: 'http://localhost:8080/andromeda/api/datafetchservice/history',
            method: 'GET',
            data: { objectId: objectId },
            dataType: 'json',
            success: function(data) {
                console.log("API response:", data);
                if (data && data.history) {
                    displayHistory(data.history);
                } else {
                    showError("No history field found in API response.");
                }
            },
            error: function(xhr, status, error) {
                console.error("AJAX error:", status, error);
                showError("Failed to fetch history data.");
            }
        });
    });
</script>

</body>
</html>
